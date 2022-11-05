#!/bin/bash

apcaccess | grep -E 'LINEV|LOADPCT|BCHARGE|TIMELEFT|BATTV|NUMXFERS|TONBATT|CUMONBATT|NOMINV|NOMPOWER' | tr '[:upper:]' '[:lower:]' | tr -d ':' | awk -F' ' '{ print "# HELP ups_"$1" UPS parameter "$1"\n# TYPE ups_"$1" gauge\nups_"$1" "$2 }' > /tmp/apc_metrics
LENGTH=$(du -b /tmp/apc_metrics | tr '\t' ' ' | cut -f 1 -d ' ')

printf "HTTP/1.1 200 Ok\r\n"
printf "Content-Type: text/plain\r\n"
printf "Content-Length: ${LENGTH}\r\n"
printf "Connection: close\r\n"
printf "\r\n"

cat /tmp/apc_metrics
