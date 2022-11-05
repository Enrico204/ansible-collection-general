# Borg role

## Variables

| Variable name | Description |
| ----- | ----- |
| `borg_version` | Borg version to install (default: depends on the playbook) |
| `borg_sha256` | Borg package hash for amd64 |
| `borg_agent` | If `true`, an "agent" will be installed in the machine (default: false) |
| `borg_agent_when` | (object) Schedule the backup at this time. Sub-fields are described below |
| `borg_agent_base_repository` | URL for the borg repositories directory, where the host-dedicated repo will be created |
| `borg_agent_server_hostkeys` | SSH Host keys for borg server (array of strings) |
| `borg_agent_ssh_private_key` | SSH private key for Borg Agent |
| `borg_agent_password` | Borg repository password, **required** |
| `borg_agent_pre` | Bash snippet to execute before the backup |
| `borg_agent_post` | Bash snippet to execute after the backup |
| `borg_agent_delayed_start_max` | Delay the agent backup schedule by a random number of seconds (`agent_delayed_start_max` is the maximum value). `0` means immediately at the schedule time |
| `borg_agent_exclude` | List of expressions for exclusion, case insensitive (default empty - note that basic exclusions are set) |
| `borg_agent_backup_paths` | Paths to backup (default `/`) |
| `borg_agent_custom_opts` | Any custom options |
| `borg_agent_services` | Borg agent service list. See below |
<!--
| `rclone` | Installs `rclone` and configure a remote sync with rclone, (default: false) |
| `rclone_prune` | Do a periodical pruning of rclone remote repository, (default: false) |
| `rclone_config_path` | Rclone configuration path (on the remote machine) |
| `rclone_repository` | Rclone repository URL |
| `rclone_password` | Rclone borg repository password | -->

`borg_agent_when` describes when the backup will take place. It has the following structure (field values can be any value accepted by the `cron` syntax):

| Field     | Default |
| --------- | ------- |
| `hour`    | `0`     |
| `minute`  | `0`     |
| `weekday` | `*`     |
| `month`   | `*`     |
| `day`     | `*`     |

## Borg "agents"

A borg "agent" is actually a script with some defaults, and a cronjob, for backups.

I use these "agents" for automatic backups in workstations and servers.

## Borg "service backup"

To backup a service (e.g. MySQL database), a special variable can be provided: `borg_agent_services`. It must be a list of objects describing a service to be backed up. The host where the variable is specified will be used as a "backup proxy" (meaning that backups will be launched from there).

Currently, these services are supported:

* MySQL/MariaDB via `mysqldump`
* PostgreSQL via `pg_dump`
* Mikrotik routers via `ssh`
* Redis via `redis-cli`

Please make sure that the "backup proxy" host have these tools installed. TODO: install them via Ansible in this playbook

Each "service" object have these variables:

| Variable name | Description |
| ------------- | ----- |
| `type`        | Service type. One of: `mysql`, `pgsql`, `mikrotik`, `redis`. |
| `name`        | Service name. It will be used as: backup set name, backup file name. Use these characters for best compatibility: `[0-9A-Za-z._-]` |
| `host`        | Target host name. E.g. the DBMS server name/IP for MySQL |
| `port`        | Port to connect to. Standard ports will be used if not specified |
| `user`        | Username for authentication (ignored in Redis) |
| `pass`        | Password for authentication (ignored in Mikrotik) |
| `ssh_privkey` | Mikrotik-only. SSH private key for authentication |
| `filename`    | File name inside the backup set. Default: depends on the service type |
| `database`    | PostgreSQL-only. Specify the name of the database to backup |
| `databases`   | MySQL-only. Specify a list of database names to backup. If not specified, all databases will be saved |
| `when`        | Schedule for the service backup. Same structure as `borg_agent_when` (see above). Default: 2:00 a.m. |

To backup a remote share (NFS, CIFS, etc.), use a "standard" agent inside a dedicated machine/container instead (hint: use FUSE or `mount` utilities and specify the backup path in the agent config).

## Inventory example

```yaml
```

# Addendum

## Create backup user in MySQL

```sql
CREATE USER 'backupuser'@'127.0.0.1' IDENTIFIED BY 'super-secret-password';
GRANT SELECT, SHOW VIEW, LOCK TABLES, RELOAD, REPLICATION CLIENT ON *.* TO 'backupuser'@'127.0.0.1';
```

## Create backup user in PostgreSQL

```sql
CREATE ROLE backupuser WITH LOGIN PASSWORD 'super-secret-password';
GRANT CONNECT ON DATABASE dbname TO backupuser;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO backupuser;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO backupuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO backupuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO backupuser;
```

# Roadmap

* Document the minimum set of privileges for backups in services (Mikrotik/MySQL/PostgreSQL/etc.)
* Merge with restic
* Get password from Hashicorp Vault
