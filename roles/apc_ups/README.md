# `apcupsd` role

This role configures a Linux system with `apcupsd`.

## Variables

| Variable name       | Description |
| ------------------- | ----- |
| `apcupsd_enable`    | APC UPS daemon enabled |
| `apcupsd_metrics`   | Whether the metrics server should be enabled or not |
| `apcupsd_listen`    | NIS listen to |
| `apcupsd_host`      | NIS connect to |
| `apcupsd_port`      | NIS connect to port |
| `apcupsd_offscript` | Script to execute when shutting down |
