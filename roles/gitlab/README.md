# GitLab role

## Variables

| Name | Description |
| ----- | ----- |
| `gitlab_version` | GitLab version to install. If not specified, latest version is installed. If not specified and `gitlab_bkfile` is specified, the version number is extracted automatically from backup |
| `gitlab_external_url` | External URL for GitLab |
| `gitlab_bkfile` | Local backup file to restore, if any. See footnotes |
| `gitlab_bkcfg` | Configuration file backup (e.g., `/etc/gitlab` in Omnibus). See footnotes |
| `test_mode` | If `true`, some configuration will be changed right after the restore: disable LE certificates, NGINX and LDAP, and change the public URL to `gitlab_external_url` |

Note: restore supports only standard GitLab backup file names. See the [backup/restore] page in GitLab documentation for details.
Alternatively, this check can be overridden by specifying `gitlab_version` together with `gitlab_bkfile`.

Note 2: the restore is performed only if both `gitlab_bkfile` and `gitlab_bkcfg` are specified.
