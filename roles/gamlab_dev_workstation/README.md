# Dev role

Base development workstation used in Gamification Lab. Supports Linux (Debian) and macOS.

This role requires the `apt` role to be executed before.

## MacOS requirements

This playbook requires a macOS with Xcode command line tools installed. To prepare a script for automate the installation workflow (CLI tools included) use [MDS](https://twocanoes.com/products/mac/mac-deploy-stick/).

It was tested with Monterey and Python 3.10.

## Variables

| Name | Description |
| ----- | ----- |
| `x11` | If `true`, enables X11 tools |
| `disable_mitigations` | If `true`, remove mitigations for Spectre/Meltdown |
| `background_image` | Path to the background image for the login manager |
| `install_script` | Add the install script for user-only executables |
| `build_tools` | Install base build tools - Default: true (both macOS and Linux) |
| `macos_disable_updates` | Whether to disable auto-updates features or not (useful in CI/CD VMs) |
| `macos_xcode_url` | Xcode URL. If specified, XCode will be downloaded from this URL and installed |
| `macos_xcode_version` | Xcode version (you need to specify the version present at the URL to avoid wasteful installs) |

## MacOS VNC

This playbook used to enable VNC for remote access / debugging / guacamole. Unfortunately, this is not possibile anymore when using macOS Monterey. VNC should be enabled locally in the System Preferences panel (via GUI).

## Known issues

* If macOS stops replying to SSH/VNC after a while, try enabling the firewall.
* macOS workstations does not have Docker
