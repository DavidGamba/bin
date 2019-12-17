#!/bin/bash

if [[ $# < 2 ]]; then
  cat <<HELP
Wrapper script for ansible-playbook to apply single role.

Usage: $0 <host-pattern> <role-name> [ansible-playbook options]

Examples:
  $0 dest_host my_role
  $0 custom_host my_role -i 'custom_host,' -vv --check
HELP
  exit
fi

HOST_PATTERN=$1
shift
ROLE=$1
shift

echo "Trying to apply role \"$ROLE\" to host/group \"$HOST_PATTERN\"..."

export ANSIBLE_ROLES_PATH="$(pwd)/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
ansible-playbook "$@" /dev/stdin <<END
---
- hosts: $HOST_PATTERN
  roles:
    - $ROLE
END
