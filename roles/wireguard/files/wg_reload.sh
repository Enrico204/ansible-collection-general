#!/usr/bin/env bash

if [ "$1" == "" ]; then
    echo "Usage: $0 <wireguard-interface>"
    exit 1
fi

wg syncconf "$1" <(wg-quick strip "$1")
