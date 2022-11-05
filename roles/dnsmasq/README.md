# dnsmasq role

This role install and configure `dnsmasq` as a local DNS server. Optionally, `dnsmasq` can be configured as DHCP server and PXE server for booting Debian installed (with preseed) or `netboot.xyz` images.

## Requirements

* jmespath

## Variables

| Name                  | Description |
| --------------------- | ----- |
| `conditional_fwd`     | Conditional forwarders |
| `ipalias`             | Replace IPs in DNS replies (for DNS split-horizon) |
| `addresses`           | Static DNS <-> IP mapping |
| `static_hosts`        | Static DNS <-> IP mapping for hosts (adds PTR) |
| `domains`             | Domain(s) to configure in `dnsmasq` as local domains (includes `dhcp4`, see example below) |
| `dnsmasq_custom_cfg`  | Any `dnsmasq` custom config |
| `read_only_root`      | If the storage is read only or not. Setting this variable to true disables the lease file and other things |
| `nextdns_id`          | NextDNS identifier. If specified, `stubby` will be installed to use NextDNS DoT/DoH |
| `nextdns_name`        | NextDNS device name. It should contain only a-z, A-Z, 0-9 and - |
| `listen_interface`    | Listen interface for DHCP/DNS (default: host IPv4 address on the interface with the default route) |
| `pxe`                 | If `true`, configures a PXE environment for Debian PXE install and others |
| `pxe_debian_preseeds` | List of preseeds to configure in PXE |
| `pxe_rpi`             | If not empty, the dnsmasq/PXE server will support Raspberry Pis PXE. RPi boot and root images will be downloaded. See below for each item structure |
| `pxe_rpi_nfs_root`    | NFS root directory. It will be used to store the Raspberry Pi root dirs. It should be writable, and big enough to handle multiple RPi base images |
| `ssh_pubkey`          | List of (strings) SSH public keys to add to `root` user inside RPis |

For each item in `domains`:

| Name     | Description |
| -------- | ----- |
| `name`   | Domain name (FQDN) for DHCP/subnet |
| `subnet` | Subnet of the domain |
| `dhcp4`  | Configure a DHCPv4 for this domain name / subnet |

Object `domains.dhcp4` contains:

| Name     | Description |
| -------- | ----- |
| `begin`  | First IP of the DHCP pool. Do not specify if the DHCP should supply only static assignments |
| `end`    | Last IP of the DHCP pool. Do not specify if the DHCP should supply only static assignments |
| `gw`     | Default gateway |
| `mask`   | Subnet mask (default: `255.255.255.0/24`) |
| `lease`  | Lease duration (default: `168h`) |
| `dns`    | DNS server (default: host IPv4 address on the interface with the default route) |
| `static` | Static DHCP assignments list, see below |

For each item in `domains.dhcp4.static`:

| Name   | Description |
| ------ | ----- |
| `mac`  | MAC address |
| `name` | Host name |
| `ip`   | IPv4 address |

For each item in `pxe_rpi`:

| Name   | Description |
| ------ | ----- |
| `id`   | RPi Serial |
| `mac`  | RPi MAC Address |
| `name` | Host name |
| `domain` | Host domain |
| `ip4`  | IPv4 address of the RPi |

## Roadmap

* Windows 10 PXE install (WinPE live?)
* Generic ISO boot? From HTTP?
* Live Linux from NFS / LTSP?

## Example

```yaml
conditional_fwd:
  - { name: internal.domain, ip: 192.0.2.1 }
  - { name: 1.168.192.in-addr.arpa, ip: 192.0.2.1 }
static_hosts:
  - { name: host1.my.domain.com, ip4: 192.0.2.5, ip6: 2001:db8::1 }
domains:
  - name: my.domain.com
    subnet: "192.168.1.0/24"
    dhcp4: { begin: 192.168.1.100, end: 192.168.1.200, gw: 192.168.1.1 }
pxe: true
pxe_debian_preseeds:
  - tag: tagname
    label: Deploy custom debian 1
    path: ./files/preseed.cfg
```

## Raspberry Pi PXE

### SD cards (old RPis
)
Some newer RPis can boot without SD card. In that case, skip this section.

Basically, we need to download the [`bootcode.bin`](https://github.com/raspberrypi/firmware/raw/master/boot/bootcode.bin)
and place it in a empty FAT32 (`mkfs.vfat`) partition.

`sfdisk` dump for the SD card (pass it on stdin):

```
label: dos
label-id: 0x2dcfb481
device: /dev/mmcblk0
unit: sectors

/dev/mmcblk0p1 : start=        8192, size=      524288, type=c
```

Note that the type and the start of the partition needs to match this dump, otherwise the RPi won't boot.

### Windows 10 PXE

TODO:

```
wpeinit
ping -n 10 localhost
net use n: \\172.27.0.4\software password /user:username
n:\win10\setup.exe
```