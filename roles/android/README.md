# Android dev role

## Variables

| Name | Description |
| ----- | ----- |
| `android_sdk_build_tools` | Android SDK build tools |
| `android_sdk_cli_version` | Android Command Line tools version |
| `android_sdk_cli_sha256` | Android Command Line tools archive sha256 |
| `android_sdk_packages` | Android SDK packages to install (array) |
| `android_sdk_basedir` | Directory where the Android SDK should be installed (default `~/Android/Sdk`) |
| `android_sdk_set_path` | Whether to configure the user PATH in `~/.bash_aliases` for Android SDK tools |
| `install_studio` | Set to `true` to install Android Studio IDE |
| `android_studio_version` | Android Studio IDE version |
| `android_studio_build` | Android Studio build for `android_studio_version`. Must match the one in the package |

## All users vs current user

Android SDK may work when installed in read only directory, but:
* user won't be able to install SDKs and others tools/platforms
* Android Studio won't detect the SDK

To install the Android SDK in a shared environment (where users can change over
time in a workstation), install it inside a directory (like `/opt/androi-sdk`)
using `flutter_basedir`, and disable `flutter_set_path`. Then it's up to you
to create a script that clones `/opt/flutter` inside the user home dir (and set
the `PATH` accordingly). See `gamlab_dev_workstation` as example.
