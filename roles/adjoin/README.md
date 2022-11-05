# AD join

This role supports Linux (Debian and related) via SSSD and macOS.

## Variables

| Variable name | Description |
| ----- | ----- |
| `ad_domain_fqdn` | AD domain FQDN |
| `ad_admin_user` | AD domain admin username |
| `ad_admin_pass` | AD domain admin password |
| `ad_default_groups` | Default local groups, comma separated (default: `plugdev`) - Linux only |
| `ad_disable_gpo` | Disable GPO processing (very old/buggy Samba versions) - Linux only |
