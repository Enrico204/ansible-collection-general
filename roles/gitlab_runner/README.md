# GitLab role

Supported operating systems:

* Debian/Ubuntu
* macOS

## Variables

| Name                 | Description |
| -------------------- | ----- |
| `gitlab_admin_token` | Token for GitLab administration, used to add/remove/modify runners. Ignored if `runner` is empty |
| `runner_reg_url`     | Runner registration URL (aka: the GitLab instance URL). Ignored if `runner` is empty |
| `runner_known_hosts` | Runner host `~/.ssh/known_hosts` initial content |
| `runner_gitconfig`   | Runner host `~/.gitconfig` initial content |
<!-- | `runner_concurrent`  | How many concurrent runners are allowed to run (default: 1) | -->
| `runners`            | Runners list. Each item is a runner instance (dictionary - see below). If empty, only the GitLab runner executable is installed |

### `runners` structure

For most of values you can refer to the [official GitLab runner documentation](https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-executors).

Right now, only `virtualbox` and `docker` are supported. VirtualBox and docker should be installed separately.

| Key                    | Required | Description |
| ---------------------- | -------- | ----- |
| `name`                 | †        | Runner name. Must be unique. It will be prepended by the runner host name |
| `tags`                 |          | Array of tags |
| `executor`             | †        | Executor (e.g., `docker`) |
| `output_limit`         |          | The log output limit |
| `ssh_user`             | •        | SSH username (various runners) |
| `ssh_pass`             | •        | SSH password (various runners) |
| `vbox_vmname`          | •        | VirtualBox executor: VM name |
| `docker_default_image` |          | Docker executor: default image |
| `docker_auth_config`   |          | Docker executor: auth config in JSON (e.g., `{"auths":{"git.example.com":{"auth":"base64encoded_user_colon_pass=="} }}`). The format is the same as `~/.docker/config.json`. One line. |

* †: always required
* •: required only when the relative executor is chosen

### Limitations:

* No tags support (see next item)
* No auto-registration support for runner instances. The specific runner token should be provided in the config.
* Only few executors supported

TODO: support KVM using custom scripts
