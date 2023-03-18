#!/usr/bin/env bash
set -eou pipefail

OID=iso.3.6.1.4.1.8072.1.3.2.3.1.1.7.115.121.115.116.101.109.100

HOST=""
COMMUNITY=""

while getopts ":H:C:c:w:" opt; do
    case $opt in
        H)
            HOST=$OPTARG
            ;;
        C)
            COMMUNITY=$OPTARG
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

OIDVAL="$(snmpget -t 10 -Oqv -c $COMMUNITY -v 2c $HOST $OID | tr -d '"')"
if [ "$OIDVAL" == "No Such Instance currently exists at this OID" ]; then
    echo "CRITICAL: Error querying ID: $OIDVAL"
    exit 2
fi

LINE=($OIDVAL)

if [ "$OIDVAL" == "" ]; then
    printf "CRITICAL: No systemd information available."
    exit 2
elif [ "$OIDVAL" == "degraded" ]; then
    printf "CRITICAL: Systemd status degrated"
    exit 2
elif [ "$OIDVAL" != "running" ]; then
    printf "WARNING: Systemd status $OIDVAL"
    exit 1
fi

printf "OK: Systemd status $OIDVAL"
exit 0
