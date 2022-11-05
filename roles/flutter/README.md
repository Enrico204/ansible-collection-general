# Flutter role

## Variables

| Name                | Description |
| ------------------- | ----- |
| `flutter_version`   | Flutter version to install |
| `flutter_sha256`    | Flutter archive tar.xz sha256 |
| `flutter_basedir`   | Flutter install base dir (default: `~/.flutter-bin`) |
| `flutter_set_path`  | Set Flutter path in `~/.bash_aliases` script (default: `true`) |
| `flutter_multiuser` | Do not install flutter. Instead, install a dummy command "flutter" that installs flutter for the current user |

## All users vs current user

Flutter won't work when installed in read only directory
([the upstream bug is still open at the time of writing](https://github.com/flutter/flutter/issues/91255)).

To install Flutter in a shared environment (where users can change over time
in a workstation), install Flutter inside a directory (like `/opt/flutter`)
using `flutter_basedir`, and disable `flutter_set_path`. Then it's up to you
to create a script that clones `/opt/flutter` inside the user home dir (and set
the `PATH` accordingly). See `gamlab_dev_workstation` as example.

# DRAFTS/TODO `.profile` for auto user local install of flutter

```bash
export PATH="$PATH:$HOME/flutter/bin"
command -v flutter > /dev/null
if [ $? -ne 0 ]; then
        flutter() {
                command -v flutter > /dev/null
                if [ $? -ne 0 ]; then
                        echo "Installing flutter..."
                        curl https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_2.10.5-stable.zip -o flutter.zip
                        unzip flutter.zip
                        rm -f flutter.zip
                fi
                ~/flutter/bin/flutter $@
        }
fi
```
