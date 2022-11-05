#!/usr/bin/env bash

export LC_ALL=C

if [ ! -e "/var/cache/apt/pkgcache.bin" ]; then
    printf -- "-1 -1 -1 -1 -1 -1\n"
    exit 0
fi

LAST_UPDATE=$(stat -c %Y /var/cache/apt/pkgcache.bin)

if [ "$(cat /tmp/apt.lastupdate)" != "$LAST_UPDATE" ]; then
    apt-get dist-upgrade --just-print > /tmp/apt.dist-upgrade
    echo $LAST_UPDATE > /tmp/apt.lastupdate
fi

LINE=($(cat /tmp/apt.dist-upgrade | grep "newly installed"))
SECURITY=$(cat /tmp/apt.dist-upgrade | grep "^Inst" | grep -ic -- "-security")
PKGS=$(cat /tmp/apt.dist-upgrade | grep "^Inst" | cut -f 2 -d ' ' | xargs echo)

UPGRADED=${LINE[0]}
NEW=${LINE[2]}
TO_REMOVE=${LINE[5]}
KEPT_BACK=${LINE[9]}

printf "%s %s %s %s %d %d %s\n" $UPGRADED $NEW $TO_REMOVE $KEPT_BACK $LAST_UPDATE $SECURITY "$PKGS"
