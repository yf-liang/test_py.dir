#!/bin/bash 
set -x
# $ scp vagrant@vag5:/home/vagrant/aws_ec2_partname.txt  /home/projects/test_py.dir/
# $ scp vagrant@vag5:/home/vagrant/vm_util3.py           /home/projects/test_py.dir/

cp /home/projects/vag.dir/vag_util.sh /home/projects/test_py.dir/

cd /home/projects/test_py.dir
git status
git add .
git commit -a -m "`date '+%b-%d-%Y %H:%M;'`: eod backup"

echo "# Username for 'https://github.com': yf-liang"
echo '# Password for 'https://yf-liang@github.com': Jack2012$'
git push origin master

git config --list

