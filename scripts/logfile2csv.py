#!/usr/bin/python

# logfile2csv.py
# Jeremy Singer
# 4 Aug 2015

# simple Python script to transform
# textual log dump from tinylog.txt
# into a CSV file for weka

# Part of Victor's summer intern project

import re
import sys
import warnings

# read log file name from input
assert len(sys.argv)>1, "supply filename as parameter"
logfilename = sys.argv[-1]

#print "reading from file: " +logfilename

currentCallSite = ""
buildingCallSite = False

# list of all callsites
callSites = []

# go through logfile line by line
with open(logfilename) as logfile:
    for line in logfile:
        if buildingCallSite:
            if 'DATA FORGOTTEN' in line:
                # end of call site
                buildingCallSite = False
                dataForgotten = int((line.strip().split())[2])
                # add this call site to list
                if currentCallSite not in callSites:
                    #and dataForgotten == 1:
                    callSites.append(currentCallSite)
                # then init empty new currentCallSite
                currentCallSite = ""
            else:
                # add this line to currentCallSite
                currentMethod = re.search('(\S+(java|Native Method|Unkown Source)\S+)', line)
                print "line is:" + line
                
                if currentMethod:
                    currentCallSite = currentCallSite + currentMethod.group(0)
                    print "current call site is: " + currentCallSite

        if "around" in line:
            # jsinger - is this the most robust aspect RegExp?
            print "found advice: " + line
            buildingCallSite = True



print "number of unique call sites: " + str(len(callSites))

i = 0
for currentCallSite in callSites:
    print str(i) + ":" + currentCallSite 
    i = i + 1
