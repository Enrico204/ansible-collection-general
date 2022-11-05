# SNMP role

Configure SNMPv2. This role was meant to be used together with icinga2, but it could be useful with other monitoring tools.
Tested on with Debian/Ubuntu, Mikrotik and macOS.

## Variables

| Name              | Description |
| ----------------- | ----- |
| `snmpd_contact`   | Contact info |
| `snmpd_location`  | Location info |
| `snmpd_listen`    | Listen IP addresses |
| `snmpd_community` | Community string |
| `snmpd_source`    | Allowed source IPv4 host or networks for community |
| `snmpd_source6`   | Allowed source IPv6 host or networks for community |

## TODO:

* Support multiple communities with basic ACLs
* Support SNMPv3
* Support sources per communities
* Support Windows
