#!/usr/bin/env bash
set -eou pipefail

# Power status: 1 => normal, 2 => failed
OID_POWERSTATUS=.1.3.6.1.4.1.6574.1.3.0

# System status: 1 => normal, 2 => failed
OID_SYSTEMSTATUS=.1.3.6.1.4.1.6574.1.1.0

OID_SYSTEMTEMP=.1.3.6.1.4.1.6574.1.2.0

# Upgrade status:
# 1. available
# 2. unavailable
# 3. connecting
# 4. disconnected
# 5. Others
OID_UPGRADEAVAIL=.1.3.6.1.4.1.6574.1.5.4.0

# Fan status: 1 => normal, 2 => failed
OID_SYSTEM_FAN=.1.3.6.1.4.1.6574.1.4.1.0
OID_CPU_FAN=.1.3.6.1.4.1.6574.1.4.2.0



HOST=""
COMMUNITY=""
WHAT=""

while getopts ":H:C:poiuyt" opt; do
    case $opt in
        H)
            HOST=$OPTARG
            ;;
        C)
            COMMUNITY=$OPTARG
            ;;
        p)
            WHAT=cpufan
            ;;
        o)
            WHAT=sysfan
            ;;
        i)
            WHAT=upgrd
            ;;
        u)
            WHAT=temp
            ;;
        y)
            WHAT=status
            ;;
        t)
            WHAT=pwr
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

case $WHAT in
    pwr)
        PWR=($(snmpget -t 10 -Oqv -c $COMMUNITY -v 2c $HOST $OID_POWERSTATUS | tr -d '"'))
        if [ "$PWR" != "1" ]; then
            printf "CRITICAL: Power failed\n"
            exit 2
        fi
        printf "OK: Power normal\n"
        ;;
    temp)
        TEMP=($(snmpget -t 10 -Oqv -c $COMMUNITY -v 2c $HOST $OID_SYSTEMTEMP | tr -d '"'))
        if [ "$TEMP" -ge 60 ]; then
            printf "CRITICAL: High temperature: %i > 60\n" "$TEMP"
            exit 2
        elif [ "$TEMP" -ge 50 ]; then
            printf "WARNING: High temperature: %i > 50\n" "$TEMP"
            exit 1
        fi
        printf "OK: Temperature: %i\n" "$TEMP"
        ;;
    cpufan)
        CPUFAN=($(snmpget -t 10 -Oqv -c $COMMUNITY -v 2c $HOST $OID_CPU_FAN | tr -d '"'))
        if [ "$CPUFAN" != "1" ]; then
            printf "CRITICAL: CPU fan failed\n"
            exit 2
        fi
        printf "OK: CPU fan ok\n"
        ;;
    sysfan)
        SYSFAN=($(snmpget -t 10 -Oqv -c $COMMUNITY -v 2c $HOST $OID_SYSTEM_FAN | tr -d '"'))
        if [ "$SYSFAN" != "1" ]; then
            printf "CRITICAL: System fan failed\n"
            exit 2
        fi
        printf "OK: System fan ok\n"
        ;;
    status)
        SYS=($(snmpget -t 10 -Oqv -c $COMMUNITY -v 2c $HOST $OID_SYSTEMSTATUS | tr -d '"'))
        if [ "$SYS" != "1" ]; then
            printf "CRITICAL: System failed\n"
            exit 2
        fi
        printf "OK: System ok\n"
        ;;
    upgrd)
        UPGRD=($(snmpget -t 10 -Oqv -c $COMMUNITY -v 2c $HOST $OID_UPGRADEAVAIL | tr -d '"'))
        if [ "$UPGRD" == "1" ]; then
            printf "WARNING: Upgrade available\n"
            exit 1
        fi
        printf "OK: No upgrades\n"
        ;;
    *)
        printf "WARNING: Missing check option"
        exit 3
        ;;
esac