#!/bin/sh
pmode="none"
test "$1" != "" && pmode=$1 && shift

# --------------------------------------------------------------------
helpme() {
echo "helpme:
$0  up   [<vaghost|deault=centos7e>]
$0  down [<vaghost|deault=centos7e>]

$0  aws_list  [<awshost|deault=vag5>]
$0  aws_make  [-host <awshost|deault=vag5>]  [-type centos(default)|ubuntu|xymon]
              [-size t2.nano(default)|t2.small] <hostname|eg:amz7c]

$0  aws_stop  [-host <awshost|deault=vag5>] [<number>|all]
$0  aws_exec  [-host <awsclient|deault=vag5>] [<number>|all]

$0  updatehosts   ## run sudo su - first to enter pswd for root access
# $0  updatehosts0  ## run as root
$0  resetssh  [-ubuntu] <awsclient|eg:amz7d]
"

}


targetuser() {
   test "$1" = "amz7vag" && echo -n "ec2-user" && return
   echo -n "vagrant"
}

# --------------------------------------------------------------------
if [ "$pmode" = "test1" ]; then
   echo "test1"
   exit
fi

# --------------------------------------------------------------------
if [ "$pmode" = "up" ]; then
set -x
   target="centos7e"
   test "$1" != "" && target="$1"
   cd $target ; vagrant up
   exit
fi

if [ "$pmode" = "down" ]; then
set -x
   target="centos7e"
   test "$1" != "" && target="$1"
   cd $target ; vagrant halt
   exit
fi

# --------------------------------------------------------------------
if [ "$pmode" = "aws_list" ]; then
   target="vag5"
   test "$1" != "" && target="$1"
   tuser="`targetuser $target`"
   echo "target: $target,  user: $tuser"
   ssh -l $tuser $target '/home/vagrant/vm_util3.py boto_awslist' > hosts.file

   pr -t -n hosts.file
   # cat hosts.file
   exit
fi

# --------------------------------------------------------------------
if [ "$pmode" = "aws_list_old" ]; then
   target="vag5"
   test "$1" != "" && target="$1"
   tuser="`targetuser $target`"
   echo "target: $target,  user: $tuser"
   ssh -l $tuser $target 'aws ec2 describe-instances --output text  --query \
       "Reservations[*].Instances[*].[InstanceId,ImageId,InstanceType,PublicIpAddress,State.Name,Tags[0].Value,Tags[1].Value,Tags[2].Value]"'  > hosts.file

   pr -t -n hosts.file
   exit
fi
if [ "$pmode" = "aws_make" ]; then
set -x
   host="vag5"
   itype="centos"
   size="t2.nano"
   test "$1" = "-host" && host="$2"   && shift && shift
   test "$1" = "-type" && itype="$2"  && shift && shift
   test "$1" = "-size" && size="$2"   && shift && shift
   target="$1"
   tuser="`targetuser $target`"

   # i2type="ami-edc04d89"
   i2type="ami-0c288fdcde212575f"
   ostype="centos7"
   test "$itype"  = "centos"       && i2type="ami-0c288fdcde212575f"
   test "$itype"  = "centos7blank" && itype="centos"      &&  i2type="ami-0ee86a6a"       
   #old:  test "$itype"  = "xymon"        && itype="centos"      &&  i2type="ami-79e5681d"
   test "$itype"  = "xymon"        && itype="centos"      &&  i2type="ami-0a0989e429d3ac97b"
   #old: test "$itype"  = "ubuntu"       && ostype="ubuntu1604" &&  i2type="ami-08a6d44d1dac90d8e"
   test "$itype"  = "ubuntu"       && ostype="ubuntu1604" &&  i2type="ami-01f43a40d497550f5"

   echo "host: $host, target=$target, tuser=$tuser, type=$itype"
   set -x
   ssh -l ${tuser} ${host} "aws ec2 run-instances --image-id $i2type \
       --count 1 --instance-type $size --key-name ca-test \
       --security-group-ids sg2-elk"   > temp.out

       # --tag-specifications 'ResourceType=instance,Tags=[ {Key=\"OStype\",Value=\"${ostype}\"} ]'"  
   cat temp.out
   awsid=`grep InstanceId temp.out | awk -F\" '{print $4}'`

   # 1st one sets order, rest follow?
   # ssh -l ${tuser} ${host} "aws ec2 create-tags --resources $awsid --tags Key=fieldC,Value=noop"
   ssh -l ${tuser} ${host} "aws ec2 create-tags --resources $awsid --tags Key=Name,Value=${target}"
   ssh -l ${tuser} ${host} "aws ec2 create-tags --resources $awsid --tags Key=OStype,Value=${ostype}"

# --tag-specifications 'ResourceType=instance,Tags=[ {Key=\"OStype\",Value=\"${ostype}\"}, {Key=\"NodeID\",Value=\"${target}\"} ]'"
# --tag-specifications 'ResourceType=instance,Tags=[ {Key=\"NodeID\",Value=\"${target}\"}, {Key=\"OStype\",Value=\"${ostype}\"} ]'"

   exit
fi
#       --tag-specifications 'ResourceType=instance,Tags=[{Key=\"NodeID\",Value=\"${target}\"}]'"


# --------------------------------------------------------------------
if [ "$pmode" = "aws_stop" ]; then
# set -x
   host="vag5"
   awsfile="hosts.file"
   test "$1" = "-host" && host="$2"   && shift && shift
   target="none"
   test "$1" != "" && target="$1"     && shift 
   tuser="`targetuser $target`"

   num=1
   cat $awsfile | \
   while read x; do
      echo "$num: $x"
      set -- $x
      awsid=$1
      test "$num" = "$target" -o "$target" = "all" && \
      ssh -l ${tuser} ${host} "aws ec2 terminate-instances --instance-ids $awsid"

      export num=`expr $num + 1`
   done
exit
fi


# --------------------------------------------------------------------
if [ "$pmode" = "aws_tags" ]; then
# set -x
   host="vag5"
   awsfile="hosts.file"
   test "$1" = "-host" && host="$2"   && shift && shift
   target="none"
   test "$1" != "" && target="$1"     && shift 
   tuser="`targetuser $target`"

   nvar1="" ; nvar2="" ; nvar3=""
   test "$1" != "" && nvar1=$1
   test "$2" != "" && nvar2=$2
   test "$3" != "" && nvar3=$3
   num=1
   cat $awsfile | \
   while read x; do
      # echo "$num: $x"
      set -- $x
      awsid=$1
      if [ "$num" = "$target" ]; then
set -x
         ovar1=$6 ; ovar2=$7 ; ovar3=$8
         ssh -l ${tuser} ${host} "aws ec2 delete-tags --resources $awsid --tags Key=Name,Value=$ovar2"
         ssh -l ${tuser} ${host} "aws ec2 delete-tags --resources $awsid --tags Key=OStype,Value=$ovar1"
         ssh -l ${tuser} ${host} "aws ec2 delete-tags --resources $awsid --tags Key=fieldC,Value=$ovar3"
         # echo "$ovar1 $ovar2 $ovar3"
         if [ "$nvar1" != "" ]; then
            ovar1=$nvar1 ; ovar2=$nvar2 ; ovar3=$nvar3
         fi
         # ssh -l ${tuser} ${host} "aws ec2 create-tags --resources $awsid --tags Key=Name,Value=$ovar1"
         ssh -l ${tuser} ${host} "aws ec2 create-tags --resources $awsid --tags Key=OStype,Value=$ovar2"
         # ssh -l ${tuser} ${host} "aws ec2 create-tags --resources $awsid --tags Key=fieldC,Value=$ovar3"
      fi   

      export num=`expr $num + 1`
   done
exit
fi


# --------------------------------------------------------------------
if [ "$pmode" = "aws_tags2" ]; then
# set -x
   host="vag5"
   awsfile="hosts.file"
   test "$1" = "-host" && host="$2"   && shift && shift
   target="none"
   test "$1" != "" && target="$1"     && shift 
   tuser="`targetuser $target`"

   nvar1="" ; nvar2="" ; nvar3=""
   test "$1" != "" && nvar1=$1
   test "$2" != "" && nvar2=$2
   test "$3" != "" && nvar3=$3
   num=1
   cat $awsfile | \
   while read x; do
      # echo "$num: $x"
      set -- $x
      awsid=$1
      if [ "$num" = "$target" ]; then
set -x
         ovar1=$6 ; ovar2=$7 ; ovar3=$8
         if [ "$nvar1" != "" ]; then
            ovar1=$nvar1 ; ovar2=$nvar2 ; ovar3=$nvar3
         fi
         ssh -l ${tuser} ${host} "aws ec2 create-tags --resources $awsid --tags Key=Name,Value=$ovar1"
         # ssh -l ${tuser} ${host} "aws ec2 create-tags --resources $awsid --tags Key=OStype,Value=$ovar2"
         # ssh -l ${tuser} ${host} "aws ec2 create-tags --resources $awsid --tags Key=fieldC,Value=$ovar3"
      fi   

      export num=`expr $num + 1`
   done
exit
fi

# --------------------------------------------------------------------
if [ "$pmode" = "aws_prep" ]; then
set -x
   host="vag5"
   test "$1" = "-host" && host="$2"   && shift && shift
   target="none"
   test "$1" != "" && target="$1"     && shift 
   tuser="`targetuser $target`"

   awsfile="hosts.file"

   num=1
   cat $awsfile | \
   while read x; do
      echo "$num: $x"

      if [ "$num" = "$target" ]; then

         set -- $x
         awsip=$4
         anode=$6
         ostype=$7
         # reset stored ssh key
         ssh-keygen -f "/home/yeliang/.ssh/known_hosts" -R "$anode"

# need ip of amz7c
amz7c=`ping -c 1 amz7c | grep PING | awk -F\( '{print $2}' | awk -F\) '{print $1}'`
         if [ "$ostype" = "centos7" ]; then
            ssh -o StrictHostKeyChecking=no -l ec2-user $anode "hostname"
            scp /etc/hosts.dev ec2-user@${anode}:/tmp/
            cat hosts > hosts.temp
            echo "$anode  ansible_ssh_host=$anode                            ansible_ssh_user=ec2-user" >> hosts.temp

            # update /etc/hosts, change hostname, and reboot
test "$anode" = "amz7c" && \
ansible-playbook -i hosts.temp -e "xymonip=${amz7c}" tasks/aws_atool_centos_xym.yml --extra-vars "aserver=$anode"
test "$anode" != "amz7c" && \
ansible-playbook -i hosts.temp -e "xymonip=${amz7c}" tasks/aws_atool_centos.yml --extra-vars "aserver=$anode"

# ansible-playbook -i ans_hosts -e 'xymonip=192.168.33.16' ../tasks/setup_centos_base.yml
#            ansible-playbook  -i hosts.temp tasks/aws_atool_centos.yml --extra-vars "aserver=$anode"
         fi
         if [ "$ostype" = "ubuntu1604" ]; then
            ssh -o StrictHostKeyChecking=no -l ubuntu   $anode "hostname"
            scp /etc/hosts.dev ubuntu@${anode}:/tmp/
            echo "$anode  ansible_ssh_host=$anode                            ansible_ssh_user=ubuntu"   >> hosts.temp

            # update /etc/hosts, change hostname, and reboot
            ansible-playbook  -i hosts.temp tasks/aws_atool_ubuntu.yml --extra-vars "aserver=$anode xymonip=${amz7c}"
         fi

         # # update vag5:/etc/hosts
         # ansible-playbook  -i hosts.temp vag_atool_b.yml --extra-vars "aserver=$anode"

      exit
      fi

      export num=`expr $num + 1`
   done
exit
fi


if [ "$pmode" = "aws_client" ]; then
set -x
   test "$1" = "" && exit
   
   ansible-playbook  -i hosts vag_atool_a.yml --extra-vars "aserver=$1"
   exit
fi


# --------------------------------------------------------------------
if [ "$pmode" = "aws_test" ]; then
set -x
   test "$1" != "" && \
   ansible-playbook  -i hosts vag_atool_a.yml --extra-vars "aserver=$1"
   exit
fi


# --------------------------------------------------------------------
if [ "$pmode" = "aws_desc" ]; then
set -x
   host="vag5"
   awsfile="hosts.file"
   test "$1" = "-host" && host="$2"   && shift && shift
   target="none"
   test "$1" != "" && target="$1"     && shift 
   tuser="`targetuser $target`"

      awsid=i-00dde111c2d691465
      ssh -l ${tuser} ${host} "aws ec2 describe-tags --filters \"Name=resource-id,Values=$awsid\" "
   exit
fi


# --------------------------------------------------------------------
if [ "$pmode" = "aws_tags" ]; then
set -x
   host="vag5"
   awsfile="hosts.file"
   test "$1" = "-host" && host="$2"   && shift && shift
   target="none"
   test "$1" != "" && target="$1"     && shift 
   tuser="`targetuser $target`"

      awsid=i-00dde111c2d691465
      ssh -l ${tuser} ${host} "aws ec2 create-tags --resources $awsid --tags Key=OStype,Value=myType"
   exit
fi


# --------------------------------------------------------------------
if [ "$pmode" = "updatehosts" ]; then
set -x
   ansible-playbook  -i hosts vag_atool.yml

   scp /etc/hosts.dev vagrant@vag5:/tmp/
   ansible-playbook  -i hosts vag_atool_b.yml

   # ssh -l vagrant vag5 "ssh-keygen -f '/home/vagrant/.ssh/known_hosts' -R 'amz7d'"
   exit
fi


if [ "$pmode" = "updatehosts0" ]; then
set -x
   cp  /etc/hosts.dev0                      /etc/hosts.dev
   cat hosts.file | awk '{print $6, $3}' >> /etc/hosts.dev
   cat /etc/hosts.skel /etc/hosts.dev     > /etc/hosts

fi


if [ "$pmode" = "resetssh" ]; then
set -x
   u2mode=centos
   test "$1" = "-ubuntu" && u2mode=ubuntu && shift
   test "$1" = ""        && echo "no client" && exit

   ssh-keygen -f "/home/vagrant/.ssh/known_hosts" -R "$1"
   test "$u2mode" = "centos" && ssh -l ec2-user $1 "hostname"
   test "$u2mode" = "ubuntu" && ssh -l ubuntu   $1 "hostname"
   exit
fi


# --------------------------------------------------------------------
if [ "$pmode" = "scan1" ]; then
   for i in vag5 vag6 vag7 vag8 vag9 ; do
   echo "# ---------- node: $i"
   ssh -q -l vagrant  $i "hostname"
   done
   exit
fi

if [ "$pmode" = "status2" ]; then
   for i in centos7d centos7m centos7n centos7o centos7p ubuntu16a ubuntu16b ; do
       echo "# ---------- node: $i"
       cd /home/projects/vag.dir/$i
       vagrant status
   done
   exit
fi

if [ "$pmode" = "halt2" ]; then
   # for i in centos7d centos7m centos7n centos7o centos7p ; do
   # for i in centos7d centos7n centos7o ; do
   for i in centos7d centos7n ubuntu16a; do
       echo "# ---------- node: $i"
       cd /home/projects/vag.dir/$i
       vagrant halt
   done
   exit
fi

if [ "$pmode" = "up2" ]; then
   # for i in centos7d centos7m centos7n centos7o centos7p ; do
   # for i in centos7d centos7n centos7o ; do
   for i in centos7d centos7n ubuntu16a; do
       echo "# ---------- node: $i"
       cd /home/projects/vag.dir/$i
       vagrant up
   done
   exit
fi

helpme
echo "None selected."
