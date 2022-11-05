# Icinga2 config generator

This playbook generates icinga2 configuration for a simple scenario: one icinga host checking hosts via SNMP,
ping, TLS/HTTP and others. No "agent" / web UI / database / etc.

Hosts monitored should be specified in `monitored` inventory group.

## Variables

| Name                        | Description |
| --------------------------- | ----- |
| `icinga2_api_user`          | Username for icinga API |
| `icinga2_api_pass`          | Password for icinga API |
| `icinga2_user`              | User id |
| `icinga2_user_display_name` | User display name |
| `icinga2_user_email`        | User e-mail (notifications will be sent there, if specified) |
| `icinga2_user_tg`           | Telegram user ID (notifications will be sent there, if specified) |
| `icinga2_tg_bot_token`      | Telegram bot token |

### Per host

Each monitored host may have these variables:

| Name                   | Description |
| ---------------------- | ----- |
| `icinga2_ip`           | Monitored host IP address (overrides inventory fqdn) |
| `icinga2_disks`        | Disks to monitor (via SNMP). Specify mount path (e.g. `/boot`) as array of strings |
| `icinga2_interfaces`   | Monitored NICs (via SNMP). Specify name (e.g. `eth0`) as array of strings |
| `icinga2_hostcheck`    | Icinga-specific code for the host (see below) |

* Mikrotik specific: `icinga2_disks` is not needed, the internal disk is always monitored.

### Per host config example

```yaml
icinga2_hostcheck: |
  vars.ssh_port = 1234;

  vars.ssl["www.example.com"] = {
    vars.ssl_cert_valid_days_warn = 30;
    vars.ssl_cert_valid_days_critical = 15;
  }

  vars.http_vhosts["www.example.com"] = {
    http_host = "www.example.com";
    http_address = "server.example.com";
    http_ssl = true;
    http_sni = true;
  }

icinga2_interfaces: ["eth0"]
icinga2_disks: ["/boot", "/"]
```

## Plugins

This role install some plugins:

* https://github.com/seffparker/icinga2-telegram-notification
  * remember to set `telegram_chat_id` property in users


Requirements: add `include <manubulon>` to the `icinga2.conf` file, and install `nagios-snmp-plugins`.

