# Restic role

Support matrix

| System  | `amd64` | `arm64` | `armv6l` |
| ------- | ------- | ------- | -------- |
| Debian  | y       | ?       | ?        |
| FreeBSD | y       |         |          |

## Variables

| Variable name | Description |
| ----- | ----- |
| `restic_version` | Restic version to install (default: depends on the playbook) |
| `restic_sha256_amd64` | Restic package hash for amd64 |
| `restic_sha256_armv6l` | Restic package hash for armv6l |
| `rest_server` | If `true`, the rest server will be installed (default: false) |
| `rest_server_version` | Rest server version (default: depends on the playbook) |
| `rest_server_sha256_amd64` | Restic package hash for amd64 |
| `rest_server_sha256_armv6l` | Restic package hash for armv6l |
| `rest_server_listen` | rest-server listen specification (default: `:9000`) |
| `rest_server_path` | rest-server base repository path |
| `restic_agent` | If `true`, an "agent" will be installed in the machine (default: false) |
| `restic_agent_repository` | URL for the restic repository, to be passed to `restic` executable, **required** |
| `restic_agent_password` | Restic repository password, **required** |
| `restic_agent_pre` | Bash snippet to execute before the backup. **Use `defer` to execute functions on exit, not trap!** |
| `restic_agent_post` | Bash snippet to execute after the backup. **Use `defer` to execute functions on exit, not trap!** |
| `restic_agent_delayed_start_max` | Delay the agent backup schedule by a random number of seconds (`restic_agent_delayed_start_max` is the maximum value). `0` means immediately at the schedule time |
| `restic_agent_iexclude` | List of expressions for exclusion, case insensitive (default empty - note that basic exclusions are set) |
| `restic_agent_backup_paths` | Paths to backup (default `/`) |
| `restic_agent_custom_opts` | Any custom options |
| `restic_agent_services` | Agent service definition (list of objects, see the example) |
| `restic_agent_when` | (object) Schedule the backup at this time. Sub-fields are described below |
| `rclone` | Installs `rclone` and configure a remote sync with rclone, (default: false) |
| `rclone_config_path` | Rclone configuration path (on the remote machine) |
| `rclone_repository` | Rclone repository URL |
| `rclone_password` | Rclone restic repository password |

`restic_agent_when` describes when the backup will take place. It has the following structure (field values can be any value accepted by the `cron` syntax):

| Field     | Default |
| --------- | ------- |
| `hour`    | `0`     |
| `minute`  | `0`     |
| `weekday` | `*`     |
| `month`   | `*`     |
| `day`     | `*`     |

## Restic "agents"

A restic "agent" is actually a script with some defaults, and a cronjob, for backups.

I use these "agents" for automatic backups in workstations and servers.

## Restic "service backup"

To backup a service (e.g. MySQL database), a special variable can be provided: `restic_agent_services`. It must be a list of objects describing a service to be backed up. The host where the variable is specified will be used as a "backup proxy" (meaning that backups will be launched from there).

Currently, these services are supported:

* MySQL/MariaDB via `mysqldump`
* PostgreSQL via `pg_dump`
* Mikrotik routers via `ssh`
* Redis via `redis-cli`

Please make sure that the "backup proxy" host have these tools installed. TODO: install them via Ansible in this playbook

Each "service" object have these variables:

| Variable name | Available in | Description |
| ------------- | ------------ | ----- |
| `type`        | -            | Service type. One of: `mysql`, `pgsql`, `mikrotik`, `redis`. |
| `name`        | *            | Service name. It will be used as: backup set name, backup file name. Use these characters for best compatibility: `[0-9A-Za-z._-]` |
| `filename`    | *            | File name inside the backup set. Default: depends on the service type |
| `when`        | *            | Schedule for the service backup. Same structure as `restic_agent_when` (see above). Default: 2:00 a.m. |
| `host`        | *            | Target host name / IP |
| `port`        | *            | Port to connect to. Standard ports will be used if not specified |
| `user`        | mysql<br/>pgsql<br/>mikrotik | Username for authentication |
| `pass`        | mysql<br/>pgsql<br/>redis    | Password for authentication |
| `ssh_privkey` | mikrotik     | SSH private key for authentication |
| `database`    | pgsql        | Specify the name of the database to backup |
| `databases`   | mysql        | Specify a list of database names to backup. If not specified, all databases will be saved |
| `apikey`      | portainer    | API Key for authentication |

To backup a remote share (NFS, CIFS, etc.), use a "standard" agent inside a dedicated machine/container instead (hint: use FUSE or `mount` utilities and specify the backup path in the agent config).

## Inventory example

```yaml
all:
  hosts:
    ansible-test:
  children:
    backuphosts:
      hosts:
        ansible-test:
          restic_agent_services:
            - name: nas
              script: |
                function cleanup {
                    umount /media/nas_safe/
                }
                defer cleanup
                mount /media/nas_safe/
              path: ["/media/nas_safe/"]

          rest_server: true
          rest_server_path: "/tank/"
          rclone: true
          rclone_repository: "googledrive:exampledir"
          rclone_password: verylongpassword2
          rclone_config_path: /tank/rclone/rclone.conf
      vars:
        restic_agent_repository: rest:http://1.2.3.4:8000
        restic_agent_password: verylongpassword
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
