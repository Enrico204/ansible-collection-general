This task prepares a prosody server. Optionally, it can install converse.js as client using the `mod_conversejs` module for prosody.

Note that, unless you use the `prosody_insecure_test_only` option (that skips TLS completely), you need to provide your own certificates. See here for details: https://prosody.im/doc/certificates

Example config:

```yaml
prosody_admins: ["admin@hostname"]
prosody_vhosts:
    - hostname: hostname
    muc: muc.hostname
    http_file_share: share.hostname
    proxy65: proxy65.hostname
prosody_conversejs_enabled: true
prosody_turn_enabled: true
prosody_turn_hostname: "hostname"
prosody_turn_secret: "super-secret-token"
prosody_turn_realm: "realm"
prosody_slidge_enabled: true
prosody_slidge_user_jid_validator: ".*@hostname"
prosody_slidge_secret: "super-secret-token"
prosody_slidge_upload_service: share.hostname
prosody_slidge_plugins:
    telegram:
    hostname: telegram.hostname
    matrix:
    hostname: matrix.hostname
```
