#!/bin/sh
pmode="none"
test "$1" != "" && pmode=$1 && shift

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
   echo "target: $target"
   ssh -l vagrant $target 'aws ec2 describe-instances --output text  --query \
       "Reservations[*].Instances[*].[InstanceId,ImageId,Tags[0].Value,Tags[1].Value,InstanceType,PublicIpAddress,State.Name]"'  > hosts.file
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

   i2type="ami-edc04d89"
   ostype="centos7"
   test "$itype"  = "centos" && i2type="ami-edc04d89"
   test "$itype"  = "xymon"  && itype="centos"  &&  i2type="ami-79e5681d"
   test "$itype"  = "ubuntu" && i2type="ami-08a6d44d1dac90d8e"  &&  ostype="ubuntu1604"

   echo "host: $host,  target=$target, type=$itype"
   set -x
   ssh -l vagrant ${host} "aws ec2 run-instances --image-id $i2type \
       --count 1 --instance-type $size --key-name ca-test \
       --security-group-ids sg2-elk \
--tag-specifications 'ResourceType=instance,Tags=[{Key=\"NodeID\",Value=\"${target}\"},{Key=\"OStype\",Value=\"${ostype}\"}]'"

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

   num=1
   cat $awsfile | \
   while read x; do
      echo "$num: $x"
      set -- $x
      awsid=$1
      test "$num" = "$target" -o "$target" = "all" && \
      ssh -l vagrant ${host} "aws ec2 terminate-instances --instance-ids $awsid"

      export num=`expr $num + 1`
   done
exit
fi


# --------------------------------------------------------------------
if [ "$pmode" = "aws_prep" ]; then
set -x
   host="vag5"
   awsfile="hosts.file"
   test "$1" = "-host" && host="$2"   && shift && shift
   target="none"
   test "$1" != "" && target="$1"     && shift 

   num=1
   cat $awsfile | \
   while read x; do
      echo "$num: $x"

      if [ "$num" = "$target" ]; then

         set -- $x
         anode=$3
         ostype=$4
         awsip=$6
         ssh-keygen -f "/home/yeliang/.ssh/known_hosts" -R "$anode"

         if [ "$ostype" = "centos7" ]; then
            ssh -o StrictHostKeyChecking=no -l ec2-user $anode "hostname"
            scp /etc/hosts.dev ec2-user@${anode}:/tmp/
            cat hosts > hosts.temp
            echo "$anode  ansible_ssh_host=$anode                            ansible_ssh_user=ec2-user" >> hosts.temp
         fi
         if [ "$ostype" = "ubuntu1604" ]; then
            ssh -o StrictHostKeyChecking=no -l ubuntu   $anode "hostname"
            scp /etc/hosts.dev ubuntu@${anode}:/tmp/
            echo "$anode  ansible_ssh_host=$anode                            ansible_ssh_user=ubuntu"   >> hosts.temp
         fi

         ansible-playbook  -i hosts.temp vag_atool_a.yml --extra-vars "aserver=$anode"

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
if [ "$pmode" = "updatehosts" ]; then
set -x
   ansible-playbook  -i hosts vag_atool.yml
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
