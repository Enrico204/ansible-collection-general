# Wireguard mesh ansible template

Test with Debian, Ubuntu and Mikrotik.

## Global parameters

| Name | Description |
| ----- | ----- |
| `wireguard_default_keepalive` | Default keepalive time for all hosts, in seconds. If zero, disables keepalive. Default: `30` |
| `wireguard_default_port` | Wireguard default VPN port for all hosts. Default: `13231` |
| `wireguard_default_mtu` | Default MTU for all hosts. Default: `1420` |
| `wireguard_cfg_dump_group` | (as role variable) Name of the group that contains externally-configured hosts (like smartphones) |
| `wireguard_cfg_dump_path` | (as role variable) Path where configurations for externally-configured hosts will be saved |

## Externally-configured hosts

`wireguard_cfg_dump_group` and `wireguard_cfg_dump_path` are useful in this scenario: suppose that you have a non-Ansible managed device (like a smartphone) and you still want to use this playbook to generate the configuration from the inventory.

You can add those hosts in the inventory (in a specific group, like `wgserver_roaming`) and use a playbook like:

```yaml
- hosts: all:!wgserver_roaming,!disabled
  roles:
    - name: wireguard
      vars:
        wireguard_cfg_dump_group: wgserver_roaming
        wireguard_cfg_dump_path: /tmp/
```

The result is that those hosts will be included in the configuration for all peers, and also the configuration files for these "external" hosts will be produced in `/tmp/` inside the controller machine.

## Per host parameter

Each host should have a list named `wireguard`. The list contains objects with these parameters:

| Name | Description |
| ----- | ----- |
| `name` | Interface name. Different hosts with the same interface name will be connected together |
| `vpn_ip` | IP address inside the VPN |
| `listen_port` | UDP port for listening socket |
| `mtu` | Interface MTU. Default: see `wireguard_default_mtu` |
| `privkey` | Private key |
| `pubkey` | Public key |
| `keepalive` | Keepalive in seconds (see Wireguard doc). If zero, disables keepalive. If not specified, the global default will be used. |
| `endpoint_host` | Public hostname of the host. If not specified, the inventory hostname is used instead. If empty, no endpoint will be set in the config file. |
| `endpoint_port` | Public port for Wireguard, if different than `listening_port` |

## Example inventory

```yaml
all:
  hosts:
    ansible-test:
      wireguard:
        - name: wg0
          vpn_ip: 198.51.100.1
          listen_port: 12345
          privkey: ON/WtbIYjBcrJ1vb0Jry7P0PY4OqXDsMNjCY0pVDDH8=
          pubkey: MzfNloVP2FpfFENlZ1SyUifB6L6skpX1r0dzmnNQIgE=
          keepalive: 30
          endpoint_host: 192.0.2.2
          endpoint_port: 6666

        - name: wg1
          vpn_ip: 1.2.2.1
          listen_port: 12346
          privkey: qMdkwfDQOtKfk2xPVo05fD57/JBbmxmzsa+hEkPaJ1I=
          pubkey: d5BQZzbigMSXDH1WSnjdpLRsrrHltQghBWOpyVHiTVk=
```

## Mikrotik

This playbook supports Mikrotik RouterOS hosts. Interfaces will be matched by name. All unknown peers for managed interfaces will be removed.

Mikrotik requires `community.routeros` collection:

```sh
ansible-galaxy collection install community.routeros
```

See https://docs.ansible.com/ansible/latest/network/user_guide/platform_routeros.html

To connect to the Mikrotik host, use something like this in the inventory:

```yaml
ansible_connection: ansible.netcommon.network_cli
ansible_network_os: community.network.routeros
ansible_user: admin+cet1024w
ansible_password: admin
ansible_become: true
```

replace `admin`/`admin` with user and pass. `+cet1024w` is a special command for RouterOS, it should be specified after the username (see the doc).

# TODO

Replace the part that deletes peers with comments with `difference()` and other internal Ansible tools.
