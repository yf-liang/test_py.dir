#!/bin/sh
set -x
anode=amz7b
test "$1" != "" && anode="$1"

auser=ec2-user
echo "$anode  ansible_ssh_host=$anode                            ansible_ssh_user=$auser" > hosts

ansible -i hosts -m ping $anode
echo "press ENTER to continue...." ; read x

ascript=simple_centos_nginx.yml
anote=centos_nginx
# ansible-playbook  --check -i hosts -e 'ansible_python_interpreter=/usr/bin/python3' \
#                   $ascript --extra-vars "aserver=$anode anote=$anote"

echo "press ENTER to continue...." ; read x

ansible-playbook  -i hosts \
                  $ascript --extra-vars "aserver=$anode anote=$anote"
