#!/usr/bin/python


import sys
import re

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


if sys.argv[1] == "test2":
   phoneNumRegex = re.compile(r'\d\d\d-\d\d\d-\d\d\d\d')
   mo = phoneNumRegex.search('My number is 415-555-4242.')
   print('Phone number found: ' + mo.group())

   # grouping
   phoneNumRegex2 = re.compile(r'(\(\d\d\d\))-(\d\d\d-\d\d\d\d)')
   mo = phoneNumRegex2.search('My number is 415-555-4242.')
   print mo.groups()
   # print mo2.group(1) 
   # print mo2.group(2)
   # print mo2.group(0)
   # print mo2.group()
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
msg = _('''-------------------
items: {v1}
       {v2}
-------------------
Enter choice>''')
print (msg)
