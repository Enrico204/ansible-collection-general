# Grafana monitor (kiosk)

This playbook can be used to configure a machine with lightdm (and possibly XFCE) to auto-login and open `grafana-kiosk` at login. It supports multiple screen.

## Variables

| Name | Description |
| ----- | ----- |
| `grafana_username` | Username for Grafana self hosted |
| `grafana_password` | Password for Grafana self hosted |
| `grafana_monitors` | Monitor configuration (list). Each item is an object, the syntax is presented below |
| `delay_between_monitors` | Wait for a delay before configuring each monitor |

### Monitor

| Name | Description |
| ----- | ----- |
| `output` | The name of the output (you can see it using `xrandr` or `lxrandr`) |
| `rotate` | Possible rotation (normal, inverted, left, right) |
| `primary` | If the screen is "primary" (i.e. the default one) |
| `url` | URL to load |
| `below` | Indicates that this monitor is below the specified monitor (optional) |
| `above` | Indicates that this monitor is above the specified monitor (optional) |
| `left-of` | Indicates that this monitor is left of the specified monitor (optional) |
| `right-of` | Indicates that this monitor is right of the specified monitor (optional) |

## Example

In this example we have a self-hosted grafana using `username-for-grafana-web` / `password-for-grafana-web` for auth.
There are 4 screens: two with normal rotation, two with inverted rotation (above "normal" screens).

```yaml
all:
  hosts:
    grafana-monitor:
      grafana_username: username-for-grafana-web
      grafana_password: password-for-grafana-web
      grafana_monitors:
        - output: DP-0
          rotate: "inverted"
          primary: true
          url: "https://grafana/playlists/play/1"
        - output: HDMI-0
          below: DP-0
          url: "https://grafana/playlists/play/2"
        - output: DP-2
          rotate: "inverted"
          right-of: DP-0
          url: "https://grafana/playlists/play/3"
        - output: DP-4
          below: DP-2
          url: "https://grafana/playlists/play/4"
```