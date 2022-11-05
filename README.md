# Ansible Collection - enrico204.general

This repository contains an Ansible collection I use to configure my servers/PCs and manage hosts for projects I'm collaborating with.

## Ansible compatibility

Tested with Ansible core 2.13.1

For now, there are no plugins/modules, so there are no dependencies.

## Included content

Since I kept these roles in my internal repository until now, I'm converting the documentation for roles to the standard way for collections.

Currently, each role directory should contain a README.md file with relevant instructions.

## Install this collection

Add this to your `requirements.yml` file:

```yaml
collections:
    # you can use other mirrors here, like GitHub
  - name: https://gitlab.com/Enrico204/ansible-collection-general.git
    type: git
    version: master
```

I may or may not decide to push this collection into Ansible Galaxy in the future. For now, this is the only supported way.

## License

[`GNU GPLv3`](LICENSE).
