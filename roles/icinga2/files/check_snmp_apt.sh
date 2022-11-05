#!/usr/bin/env bash
set -eou pipefail

OID=iso.3.6.1.4.1.8072.1.3.2.3.1.1.3.97.112.116

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
    echo "Error querying ID: $OIDVAL"
    exit 2
fi

LINE=($OIDVAL)

if [ "${LINE[0]}" == "-1" ]; then
    printf "CRITICAL: No update information available. Run apt update to refresh index"
    exit 2
fi

PKGS="${LINE[@]:6}"

if [ ${LINE[5]} -gt 0 ]; then
    printf "CRITICAL: %d security updates pending: %s\n" ${LINE[5]} "$PKGS"
    exit 2
fi

NOWTS=$(date +%s)
ONE_MONTH=$(($NOWTS - 2592000))
if [ ${LINE[4]} -lt $ONE_MONTH ]; then
    printf "WARNING: update not checked in 30 days\n"
    exit 1
fi

EXITSTATUS=0
if [ ${LINE[0]} -gt 0 ]; then
    printf "WARNING: "
    EXITSTATUS=1
else
    printf "OK: "
fi

printf "%i updates pending (%i new, %i to remove, %i kept back): %s\n" ${LINE[0]} ${LINE[1]} ${LINE[2]} ${LINE[3]} "$PKGS"
exit $EXITSTATUS
