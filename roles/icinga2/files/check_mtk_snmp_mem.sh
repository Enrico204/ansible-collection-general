#!/usr/bin/env bash
set -eou pipefail

OID_TOTAL=.1.3.6.1.2.1.25.2.3.1.5.65536
OID_USED=.1.3.6.1.2.1.25.2.3.1.6.65536

HOST=""
COMMUNITY=""
CRIT=90
WARN=70

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

MEM_USED=$(snmpget -Oqv -c $COMMUNITY -v 2c $HOST $OID_USED)
MEM_TOTAL=$(snmpget -Oqv -c $COMMUNITY -v 2c $HOST $OID_TOTAL)
# TODO: errors

RATIO=$(bc <<< "$MEM_USED*100/$MEM_TOTAL")

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

printf "RAM occupation %d%% (%d/%d)\n" $RATIO $MEM_USED $MEM_TOTAL
exit $EXITSTATUS
