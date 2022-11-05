# Rsyslog configuration

Install a `rsyslog` and optionally configure it to:
- forward all events to a remote destination; or
- accepts remote UDP/TCP syslog packets and forward them to a PostgreSQL database

## Variables

| Name           | Description |
| -------------- | ----------- |
| `rsyslog_psql_host` | PostgreSQL hostname |
| `rsyslog_psql_user` | PostgreSQL user name |
| `rsyslog_psql_pass` | PostgreSQL password |
| `rsyslog_psql_db` | PostgreSQL database |
| `rsyslog_relp_host` | Forward all messages to this RELP host |
| `rsyslog_relp_port` | RELP port (default: `2514`) |
| `rsyslog_tcp_host` | Forward all messages to this TCP host |
| `rsyslog_tcp_port` | TCP port (default: `514`) |
| `rsyslog_udp_host` | Forward all messages to this UDP host |
| `rsyslog_udp_port` | UDP port (default: `514`) |

The PostgreSQL user needs only `INSERT` privileges on tables and `USAGE` on sequences.

<!-- | `rsyslog_psql` | PostgreSQL connection string (example: `postgresql://rsyslog:test1234@postgres.example.com/syslog?sslmode=verify-full&sslrootcert=/path/to/cert`) |

See https://www.postgresql.org/docs/current/libpq-connect.html for connection string options.
 -->

If multiple protocol are specified for message forwarding, RELP will be configured if available, otherwise TCP or UDP (tested in this order).

## Mikrotik

This playbook supports Mikrotik hosts by configuring syslog forwarding to rsyslog (no PostgreSQL or RELP/TCP support).
