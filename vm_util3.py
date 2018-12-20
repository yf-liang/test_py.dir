#!/usr/bin/env python

from __future__ import print_function

import boto3

import json
import subprocess
import sys
# import sqlit3

from random import randint
import os, json, datetime, getpass, pprint


# ---------- function ----------
def do_cmd(cmd0):

    output0 = ""
    try:
        output0 = subprocess.check_output(cmd0, shell=True,
                                     stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError:
        print ('Execution of "%s" failed!\n' % cmd0)
        return (1, output0.rstrip())

    return(0, output0.rstrip())

# ---------- function ----------
def helpme():
    print (sys.argv[0])
    print ("""
    <program>  <substr1>  [<substr2> <substr3> ...]
    """)
    return

# ---------- function ------------------------------
def proc_arg():
    global awsfile
    global host
    global target

    if (sys.argv[1] == "-host"):
       host = sys.argv[2]
       del sys.argv[1:2]

    if (sys.argv[1] == "-host"):
       host = sys.argv[2]
       del sys.argv[1:2]

    return

# ---------- main ----------------------------------
nparms = len( sys.argv )
if nparms <= 1:
   helpme()
   sys.exit()

awsfile = "hosts.file"
host    = "vag5"
target  = "none"

aparm   = sys.argv[1]
del sys.argv[1:1]
proc_arg()


# --------------------------------------------------
if aparm == "test1":
   print ("test1")
   sys.exit()

# --------------------------------------------------
if aparm == "aws_dump":
   outfile = "output.json"
   # tuser   = targetuser(target)
   # cmd = "ssh -l " + tuser + " " + host + " 'aws ec2 describe-instances '"  + " > " + outfile
   cmd = "aws ec2 describe-instances > " + outfile
   print (":" + cmd + ":")
   (result0, output0) = do_cmd (cmd) ; print (output0)
   sys.exit()

# --------------------------------------------------
if aparm == "aws_read":
   outfile = "output.json"
   # tuser   = targetuser(target)

   with open( outfile ) as handle:
      dictdump = json.loads(handle.read())

      for x in dictdump['Reservations']:
          # print ( x['Instances']['InstanceId'] )
          # print ( x['Instances'][0] )
          print ( x['Instances']['Instances'] )


   # print (":", len(dictdump),  ":")

   # print ( json.dumps(dictdump, sort_keys=True, indent=4) )

   # print ( dictdump )
   # try:
   #     decoded = json.loads(dictdump)

   #     # Access data
   #     for x in decoded['Reservations']:
   #         print ( x['Instances'] )

   # except (ValueError, KeyError, TypeError):
   #     print ( "JSON format error" )
   sys.exit()

# --------------------------------------------------
if aparm == "boto_awslist":
   ec2 = boto3.resource('ec2')
   # ec2 = boto3.client('ec2')

   instances = ec2.instances.all()

   # instances = ec2.instances.filter(
   #     Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
   #   Filters=[{'Name': 'instance-state-name', 'Values': ['']}])
   # instances = ec2.describe_instances()

   for instance in instances:
       iname = "" ; itype = ""
       for t2 in instance.tags:
           if (t2['Key'] == "Name"):
              iname = t2['Value']
           if (t2['Key'] == "OStype"):
              itype = t2['Value']

       # print (instance)
       print ("%-20s %-22s %-10s %-12s %-15s %-12s %-10s" % \
               (instance.id, instance.image.id, instance.instance_type, \
               instance.state['Name'], instance.public_ip_address, iname, itype))


   # print ("----------")
   # for status in ec2.meta.client.describe_instance_status()['InstanceStatuses']:
   #     print(status)

   # print ("----------")
   # ec2 = boto3.client('ec2')
   # filters = [
   #     {'Name': 'domain', 'Values': ['vpc']}
   # ]
   # response = ec2.describe_addresses(Filters=filters)
   # print(response)

   sys.exit()

