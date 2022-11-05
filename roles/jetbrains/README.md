# JetBrains role

This role installs JetBrains IDEs (except Android Studio)

## Variables

| Name | Description |
| ----- | ----- |
| `goland` | Whether install GoLand or not |
| `goland_allusers` | Install JetBrains GoLand for all users in `/opt` |
| `goland_version` | GoLand version to install |
| `goland_build` | GoLand build for `goland_version`. Must match the one in the package |
