#!/usr/bin/env bash
set -eou pipefail

OID_TOTAL=.1.3.6.1.2.1.25.2.3.1.5.131073
OID_USED=.1.3.6.1.2.1.25.2.3.1.6.131073

HOST=""
COMMUNITY=""
CRIT=95
WARN=90

while getopts ":H:C:c:w:" opt; do
    case $opt in
        H)
            HOST=$OPTARG
            ;;
        C)
            COMMUNITY=$OPTARG
            ;;
        c)
            CRIT=$OPTARG
            ;;
        w)
            WARN=$OPTARG
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

DISK_USED=$(snmpget -Oqv -c $COMMUNITY -v 2c $HOST $OID_USED)
DISK_TOTAL=$(snmpget -Oqv -c $COMMUNITY -v 2c $HOST $OID_TOTAL)
# TODO: errors

RATIO=$(bc <<< "$DISK_USED*100/$DISK_TOTAL")

EXITSTATUS=0
if [ $RATIO -gt $CRIT ]; then
    printf "CRITICAL: "
    EXITSTATUS=2
elif [ $RATIO -gt $WARN ]; then
    printf "WARNING: "
    EXITSTATUS=1
else
    printf "OK: "
fi

printf "Disk occupation %d%% (%d/%d)\n" $RATIO $DISK_USED $DISK_TOTAL
exit $EXITSTATUS
