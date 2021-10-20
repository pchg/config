#!/usr/bin/env python

# pg_diff v0.2
# Utility to display differences between PostgreSQL databases

__author__  = "Anoop Menon <codelogic_at_gmail_dot_com>"
__license__ = "GPL"
__version__ = "0.2"
__date__    = "07/07/2007"

import sys
import os
import pg
import commands
from sets import *

def showUsage():
    print """
pg_diff v%s  (%s)
%s, Copyright 2007.

pg_diff is a program that displays the table differences
between two PostgreSQL databases.

By default, it will print out the list of tables that are
different between the two databases. It can optionally also
print out the exact differences in schema. It does NOT
compare the data in the tables.

Usage: pg_diff <db1> <db2> [options]

       -s       Also print table creation SQL (uses pg_dump)
       -d       Search for differences in the attributes
                (used for finding column additions or deletions)

NOTE: currently it defaults to username 'postgres' and
      hostname 'localhost' for both databases.
      
""" % (__version__, __author__, __date__)

class PGDiff:
    def __init__(self, db1, db2, u1="postgres", u2="postgres", p1=None, p2=None, h1="localhost", h2="localhost", sql=0):
        self._db1name = db1
        self._db2name = db2
        self._db1user = u1
        self._db2user = u2
        self._db1pass = p1
        self._db2pass = p2
        self._db1host = h1
        self._db2host = h2
        self._db1 = pg.DB(dbname=self._db1name, host=self._db1host, user=self._db1user)
        self._db2 = pg.DB(dbname=self._db2name, host=self._db2host, user=self._db2user)
        self._sql = sql


    def printTableAttrDiff(self, db1, db2, table):
        att1 = db1.get_attnames(table)
        att2 = db2.get_attnames(table)
        a1diff = dict()
        a2diff = dict()
        for a in att1.items():
            if a not in att2.items():
                a1diff[a[0]] = a[1]

        for a in att2.items():
            if a not in att1.items():
                a2diff[a[0]] = a[1]

        if len(a2diff)>0 or len(a1diff)>0:
            print "\nThere are differences in the table '%s'" % table
            head = "-".ljust(67).replace(" ", "-")
            print head
            print "| %s | %s |" % (self._db1name.ljust(30), self._db2name.ljust(30))
            print head
            if len(a1diff)>0:
                right = "|".rjust(34)
                for aname,atype in a1diff.items():
                    print str("| "+aname+": "+atype).ljust(33)+"|"+"|".rjust(33)

            if len(a2diff)>0:
                left = "| ".rjust(34)
                for aname,atype in a2diff.items():
                    print "|"+left+str(aname+": "+atype).ljust(31)+"|"
            print head
        return
    
    def printTableAttr(self, db, table):
        attr = db.get_attnames(table)
        attnsize = 0
        atttsize = 0
        for attname,atttype in attr.items():
            if len(attname)>attnsize:
                attnsize = len(attname)
            if len(atttype)>atttsize:
                atttsize = len(atttype)

        attnsize+=2
        atttsize+=2
        hsize = attnsize+atttsize+7
        head = ""
        for a in range(0,hsize):
            head+="-"
        print head
        for attname,atttype in attr.items():
            print "| %s | %s |" %(attname.ljust(attnsize), atttype.rjust(atttsize))
        print head
        

    def printTableSQL(self, db, table):
        cmd = "pg_dump -O -U postgres %s -s -t %s" % (db, table)
        (st,out) = commands.getstatusoutput(cmd)
        print out

    def printDiffTables(self, deep=0):
        s1 = Set(self._db1.get_tables())
        s2 = Set(self._db2.get_tables())
        d1 = [ a for a in s1-s2 ]
        d2 = [ a for a in s2-s1 ]
        head =""
        if len(d1)>0:
            msg = "Tables in '%s' that are not in '%s'" % (self._db1name,self._db2name)
            head = ""
            for a in range(0,len(msg)):
                head+="="
            print head
            print msg
            print head,"\n"
            for t in d1:
                print "***************************************"
                print "* %s *" % t.center(35)
                print "***************************************"
                self.printTableAttr(self._db1, t)
                print ""
                if self._sql:
                    print "Table creating SQL:"
                    self.printTableSQL(self._db1name, t)

        if len(d2)>0:
            msg = "Tables in '%s' that are not in '%s'" % (self._db2name,self._db1name)
            print head
            print msg
            print head,"\n"
            for t in d2:
                print "***************************************"
                print "* %s *" % t.center(35)
                print "***************************************"
                self.printTableAttr(self._db2, t)
                print ""
                if self._sql:
                    print "Table creating SQL:"
                    self.printTableSQL(self._db2name, t)

        if deep:
            msg = " Tables that are in both databases but have different attributes"
            head = "================================================================="
            print head
            print msg
            print head

            d = s1.intersection(s2) #common tables
            for t in d:
                self.printTableAttrDiff(self._db1, self._db2, t)

        
def main(argv):
    try:
        db1 = argv[1]
        db2 = argv[2]
    except:
        showUsage()
        return

    showsql = 0
    deep = 0
    try:
        for a in argv[3:]:
            if a=="-s":
                showsql = 1
            if a=="-d":
                deep = 1
    except:
            pass
    try:
        pgdiff = PGDiff(db1, db2, sql=showsql)
        print ""
        pgdiff.printDiffTables(deep)
        print ""
    except Exception,e:
        print str(e)
        
if __name__=="__main__":
    main(sys.argv)

