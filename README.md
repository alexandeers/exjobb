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

### Roles in execution order
1. `localhost` - resets virtual machines.
2. `common` - handles prerequisite configuration necessary on all nodes.
3. `control` - sets up the cluster on the control plane and exposes variables for the workers.
4. `worker` - configures worker nodes and joins them to the cluster.

### Inventory

You will need to edit this file in order for Ansible to discover the nodes.

```ini
[control]
# x.x.x.x ...

[workers]
# x.x.x.x ...
```