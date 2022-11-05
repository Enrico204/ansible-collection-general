#!/usr/bin/env bash
set -eou pipefail

TEMPERATURES=1.3.6.1.4.1.2021.13.16.2.1
FANS=1.3.6.1.4.1.2021.13.16.3.1
VOLTAGES=1.3.6.1.4.1.2021.13.16.4.1

HOST=""
COMMUNITY=""
T_CRIT=80
T_WARN=70
F_CRIT=100
F_WARN=500
VL_CRIT=100
VL_WARN=500
CHECK_VOLTAGE=0
NORMAL_STRING="OK: Normal values"

# TODO: add filters for items

while getopts ":H:C:c:w:f:g:v" opt; do
    case $opt in
        H)
            HOST=$OPTARG
            ;;
        C)
            COMMUNITY=$OPTARG
            ;;
        c)
            T_CRIT=$OPTARG
            ;;
        w)
            T_WARN=$OPTARG
            ;;
        f)
            F_CRIT=$OPTARG
            ;;
        g)
            F_WARN=$OPTARG
            ;;
        v)
            CHECK_VOLTAGE=1
            ;;
        \?)
            echo "Invalid option -$OPTARG" >&2
            exit 3
            ;;
    esac
done

if [ "$COMMUNITY" == "" ]; then
    echo "Missing community" >&2
    exit 3
fi
if [ "$HOST" == "" ]; then
    echo "Missing host address" >&2
    exit 3
fi

# Temperatures (milli-C)
while read line; do
    OID=$TEMPERATURES.3.$(echo $line | cut -f 1 -d ' ' | rev | cut -f 1 -d '.' | rev)
    NAME=$(echo $line | cut -f 2- -d ' ' | tr -d '"')
    TEMP=$(snmpget -c $COMMUNITY -v 2c $HOST $OID -Oqv)
    TEMP=$(bc <<< "$TEMP/1000")
    if [ $TEMP -gt $T_CRIT ]; then
        printf "CRITICAL: %s temperature above critical: %f°C > %f°C\n" "$NAME" "$TEMP" "$T_CRIT"
        exit 2
    elif [ $TEMP -gt $T_WARN ]; then
        printf "WARNING: %s temperature above warning: %f°C > %f°C\n" "$NAME" "$TEMP" "$T_WARN"
        exit 1
    fi
    NORMAL_STRING="$NORMAL_STRING - $NAME: $TEMP°C"
done < <(snmpwalk -c public -c $COMMUNITY -v 2c $HOST $TEMPERATURES.2 -Oq | { grep -v "No more variables left" || true; } | { grep -v "No Such" || true; })

# Fans (RPM)
while read line; do
    OID=$FANS.3.$(echo $line | cut -f 1 -d ' ' | rev | cut -f 1 -d '.' | rev)
    NAME=$(echo $line | cut -f 2- -d ' ' | tr -d '"')
    RPM=$(snmpget -c $COMMUNITY -v 2c $HOST $OID -Oqv)
    if [ $RPM -lt $F_CRIT ]; then
        printf "CRITICAL: %s fan below critical: %f rpm < %f rpm\n" "$NAME" "$RPM" "$F_CRIT"
        exit 2
    elif [ $RPM -lt $F_WARN ]; then
        printf "WARNING: %s fan below warning: %f rpm < %f rpm\n" "$NAME" "$RPM" "$F_WARN"
        exit 1
    fi
    NORMAL_STRING="$NORMAL_STRING - $NAME: $RPM rpm"
done < <(snmpwalk -c public -c $COMMUNITY -v 2c $HOST $FANS.2 -Oq | { grep -v "No more variables left" || true; } | { grep -v "No Such" || true; })

if [ "$CHECK_VOLTAGE" == "1" ]; then
    # Voltages (milli-V)
    while read line; do
        OID=$VOLTAGES.3.$(echo $line | cut -f 1 -d ' ' | rev | cut -f 1 -d '.' | rev)
        NAME=$(echo $line | cut -f 2- -d ' ' | tr -d '"')
        VOLTS=$(snmpget -c $COMMUNITY -v 2c $HOST $OID -Oqv)
        if [ $VOLTS -lt $VL_CRIT ]; then
            printf "CRITICAL: %s voltage below critical: %f < %f\n" "$NAME" "$VOLTS" "$VL_CRIT"
            exit 2
        elif [ $VOLTS -lt $VL_WARN ]; then
            printf "WARNING: %s voltage below warning: %f < %f\n" "$NAME" "$VOLTS" "$VL_WARN"
            exit 1
        elif [ $VOLTS -gt $VH_CRIT ]; then
            printf "CRITICAL: %s voltage above critical: %f > %f\n" "$NAME" "$VOLTS" "$VH_CRIT"
            exit 2
        elif [ $VOLTS -gt $VH_WARN ]; then
            printf "WARNING: %s voltage above warning: %f > %f\n" "$NAME" "$VOLTS" "$VH_WARN"
            exit 1
        fi
        NORMAL_STRING="$NORMAL_STRING - $NAME: $VOLTS mV"
    done < <(snmpwalk -c public -c $COMMUNITY -v 2c $HOST $VOLTAGES.2 -Oq | { grep -v "No more variables left" || true; } | { grep -v "No Such" || true; })
fi

printf "%s\n" "$NORMAL_STRING"
