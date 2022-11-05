#!/usr/bin/env bash

export LC_ALL=C

LAST_UPDATE=$(stat -c %Y /var/lib/dnf/history.sqlite)

SECURITY=0
dnf check-update --assumeno --security > /dev/null 2>&1
case $? in
    100)
        SECURITY=$(dnf check-update --assumeno --security | grep -v "Last metadata expiration check" | grep -v 'Obsoleting Packages' | grep -vE '^$' | grep -vE '^\s' | wc -l)
        ;;
    0)
        ;;
    *)
        printf "error!\n"
        ;;
esac

UPGRADED=0
PKGS=""
dnf check-update --assumeno > /dev/null 2>&1
case $? in
    100)
        UPGRADED=$(dnf check-update --assumeno | grep -v "Last metadata expiration check" | grep -v 'Obsoleting Packages' | grep -vE '^$' | grep -vE '^\s' | wc -l)
        PKGS=$(dnf check-update | grep -v "Last metadata expiration check" | grep -v 'Obsoleting Packages' | grep -vE '^$' | grep -vE '^\s' | cut -f 1 -d ' ' | xargs echo)
        ;;
    0)
        ;;
    *)
        printf "error!\n"
        ;;
esac

printf "%d %d %d %s\n" "$UPGRADED" $LAST_UPDATE "$SECURITY" "$PKGS"
