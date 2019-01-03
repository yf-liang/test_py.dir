#!/bin/sh
set -x

anode=amz7v
auser=ubuntu
echo "$anode  ansible_ssh_host=$anode                            ansible_ssh_user=$auser" > hosts

ansible -i hosts -m ping $anode
echo "press ENTER to continue...." ; read x

ascript=simple_ubuntu_nginx.yml
anote=ubuntu_nginx
# ansible-playbook  --check -i hosts -e 'ansible_python_interpreter=/usr/bin/python3' \
#                   $ascript --extra-vars "aserver=$anode anote=$anote"

echo "press ENTER to continue...." ; read x

ansible-playbook  -i hosts -e 'ansible_python_interpreter=/usr/bin/python3' \
                  $ascript --extra-vars "aserver=$anode anote=$anote"
