#!/bin/bash
pmode=$1 
vfile="vag_proj.conf"

# --------------------------------------------------------------------------
if [ "$pmode" = "vag_create" ]; then
   set -x
   target=$2
   xline="`grep ^${target} $vfile`"
   set -- $xline
   new_ip=$3
   ostype=$4
   echo "press <ENTER> to continue...."  && read x

   mkdir $2
   cd    $2
   echo  "[vagnode]
${target}   ansible_ssh_host=${target}                         ansible_ssh_user=vagrant"  >  ans_hosts

   if [ "$ostype" = "ubuntu" ]; then
      vagrant init geerlingguy/ubuntu1604
      t2file="../files/t2_Vagrantfile_ubuntu"
   else
      vagrant init geerlingguy/centos7
      t2file="../files/t2_Vagrantfile_centos"
   fi

cp ../files/incl.bashrc_root     .
cp ../files/incl.bashrc_vagrant  .
cp ../files/ansible.cfg          .

cp /home/yeliang/.ssh/id_rsa.pub_yeliang_dellcx .
cp -p Vagrantfile bkup.Vagrantfile
cat $t2file | sed "s/##priv_ip##/${new_ip}/" > Vagrantfile

vagrant up
read x
exit

# cd centos7o ; vagrant ssh
cat /vagrant/id_rsa.pub_yeliang_dellcx >> ~/.ssh/authorized_keys
cat /vagrant/incl.bashrc_vagrant >> ~/.bashrc
# cat /vagrant/incl.bashrc_root >> ~root/.bashrc

[yeliang@yeliang-Inspiron-3558: /home/projects/vag.dir/centos7p ]
$ tar cvzf ../files/xymon_client_centos7.tgz ./client

# /home/projects/vag.dir/centos7c
# ssh-keygen -f "/home/yeliang/.ssh/known_hosts" -R "vag8"
scp ../files/xymon_client_centos7.tgz vagrant@vag8:/tmp/
ansible -i ans_hosts vagnode -m ping
# need ip of amz7c
# vag6:  192.168.33.16
ansible-playbook --check -i ans_hosts -e 'xymonip=192.168.33.16' ../tasks/setup_centos_base.yml 
ansible-playbook -i ans_hosts -e 'xymonip=192.168.33.16' ../tasks/setup_centos_base.yml 

ansible-playbook --check -i ans_hosts -e 'xymonip=192.168.33.16' ../tasks/setup_ubuntu_base.yml 

# [root@vag8: ~ ]
# shutdown -r now

## no need in centos_base.yml already:
## ansible-playbook --check -i ans_hosts ../tasks/setup_centos_xymonclient.yml 

vagrant halt
vagrant destroy -f
rm -rf $2

# cat /vagrant/id_rsa.pub_yeliang_dellcx >> ~/.ssh/authorized_keys
ping $target
ssh -l vagrant target hostname
fi

echo "None selected."
