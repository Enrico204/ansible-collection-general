# Server hardening

Harden the server. Tested on Debian/Ubuntu. Each step can be disabled/enabled.

## SSH

Install OpenSSH server, disable login with password and specify a good default of ciphers.

**Enabled by default**, disable configuring `ssh_hardening` to `false`.

## Firewall

This step configure a basic firewall for non-router hosts.
It's not meant to generate a complex firewall configuration, only a basic one.
The firewall can be based on `iptables` (legacy) or `nftables`.

**Disabled by default**, enable by configuring either `fw_iptables` or `fw_nftables` to `true`.

### Variables

| Name                    | Description |
| ----------------------- | ----- |
| `fw_iptables`           | Enable legacy `iptables` backend |
| `fw_nftables`           | Enable `nftables` backend |
| `fw_safe_mgmt4`         | IP addresses that are always allowed to connect to SSH (bypassing all rules, including blacklists) |
| `fw_ssh_port`           | Host SSH port, if different than 22 |
| `fw_public_services`    | Array of exposed services (see below for syntax) |
| `fw_whitelist_services` | Services exposed only for networks in whitelists |
| `fw_rules`              | Other rules |
| `fw_wan`                | WAN interfaces (needed when `fw_blacklists` is specified) |
| `fw_blacklists`         | Blacklists to load. IPs in blacklists will be blocked on all incoming connections |
| `fw_whitelists`         | Whitelists to load. Only IPs in whitelists will be allowed to connect to `fw_whitelist_services` |
| `fw_iptables_filter`    | `iptables` legacy formatted rules for `filter` table (use on complex rules, `iptables`-legacy only) |
| `fw_nft_filter`         | `nftables` formatted rules for `filter` table (use on complex rules, `nftables` only) |

#### Exposed services structure

Each service in `fw_public_services`, `fw_whitelist_services` or `fw_rules` may have these attributes:

| Name           | Description |
| -------------- | ----- |
| `proto`        | Protocol, as supported by `nftables` or `iptables`. E.g.: `tcp`, `udp`, etc |
| `port`         | Service port for the protocol (e.g.: 80) |
| `name`         | Rule name |
| `action`       | (only in `fw_rules`) Action: `accept`, `accept-if-whitelisted`, `reject`, `drop` |
| `in_interface` | (only in `fw_rules`) Inbound interface name |

For more complex rules please use `fw_iptables_filter` or `fw_nft_filter`, which allows native syntax.

### Notes on firewall rules

`fw_blacklists` and `fw_whitelists` should contains "tags" for IP lists.
These tags are defined in the `fw-lists-update.sh.j2` script.

The basic idea behind the blacklist is simple: every packet coming from an IP in the blacklist (using the `fw_wan` interface) will be dropped.
This rule acts before every rule except the `fw_safe_mgmt4`.

The basic idea behind the whitelist is: every packet coming from an IP in the whitelist for a service inside `fw_whitelist_services` will be allowed.
Other packets for `fw_whitelist_services` will be dropped.

Note that ICMP Ping is always allowed.
