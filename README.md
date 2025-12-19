# Examensjobb
Detta är nödvändiga filer för mitt examensjobb.


## Usage
The `ansible` folder contains playbooks organized in [Roles](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_reuse_roles.html) that bootstraps the environment.

### Environment variables
The playbooks make use of env vars for sensitive information.

- GUEST_ANSIBLE_USER
- GUEST_ANSIBLE_BECOME_PASS
- HOST_ANSIBLE_USER
- HOST_ANSIBLE_BECOME_PASS

### Pre-requisites
The playbook expects each guest virtual machine to have a snapshot called `original` of a SSH-able baseline Ubuntu Server system. The snapshot would ideally be captured after the initial configuration, installation and subsequent reboot, with no further changes to the system (except for copying over SSH keys).

### Roles in execution order
1. `localhost` - resets virtual machines to a snapshot.
2. `common` - handles prerequisite configuration necessary on all nodes.
3. `control` - sets up the cluster on the control plane and exposes variables for the workers.
4. `worker` - configures worker nodes and joins them to the cluster.

### Inventory

You will need to edit the [hosts](./ansible/inventory/hosts.ini) file in order for Ansible to discover the nodes.

```ini
[control]
# x.x.x.x ...

[workers]
# x.x.x.x ...
```