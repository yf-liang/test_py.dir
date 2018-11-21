#!/usr/bin/python
from __future__ import print_function    # (at top of module)

import sys
import commands

# ---------- function ----------
def test1 ():
    # default is local
    global v2
    # local v1
    v1 = "v1.local"
    v2 = "v2.local"
    
    return

# python2 syntax
# print "hello python!"

# debug:
# $ python3 -m pdb ./test01.py


# ---------- main ----------
nparms = len( sys.argv )
if nparms <= 1:
   # help()
   sys.exit()

if sys.argv[1] == "test1":
   print ("test1")
   sys.exit()

if sys.argv[1] == "var1":
   v1 = "v1"
   v2 = "v2"
   test1()
   print (v1 + " " + v2)

   sys.exit()


# ----------------------------------------------------------------------
if sys.argv[1] == "ary1":

   d = {}
   fname = "file.txt"
   with open(fname) as f:
       for line in f:
           if (not line.startswith("#")):
              # print (line.strip('\n'))
              (key, val) = line.split()
              d[ key ] = val.strip('\n')
              print ("key: " + key + "  val: " + d[ key ])
              # print ("key: " + key + "  val: " + val.strip('\n'))

       print ('v1: ' + d['v1'])
       print ('v4: ' + d['v4'])
   sys.exit()


# ----------------------------------------------------------------------
if sys.argv[1] == "sys1":
   print (sys.builtin_module_names)
   sys.exit()

# ----------------------------------------------------------------------
if sys.argv[1] == "test2":
   # print commands.getstatusoutput('dir /tmp')
   (result, output) = commands.getstatusoutput('dir /tmp')
   print (result)
   oary = output.split("\n")
   print ('\n' . join(oary))
   sys.exit()

# ----------------------------------------------------------------------
if sys.argv[1] == "test3":

   print('Hello', 'Guido')

   # no crlf
   print('aboveline> ', end='')
   print('nextline')

   # output to stderr
   print('stderr> Hello', file=sys.stderr)
   sys.exit()

# ----------------------------------------------------------------------
if sys.argv[1] == "test31":
   print ("hello python!")
   print ("")

   print ("a", "b", "c")
   print ("a" + "b" + "c")

   print ("items: %s %s %s" % ("a", "b",  "c"))

   print ("""
   hello python %s %s
   """)

   v1 = """-------------------
items: %s  
       %s  
       %s
-------------------
Enter choice>
""" % ( "a", "b",  "c")
   print (v1)


   # variable interpolation
   v1="msg1"
   v2="msg2"
   msg = ('''-------------------
items: {v1}
       {v2}
-------------------
Enter choice>''')
   print (msg)
   sys.exit()
