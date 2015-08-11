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
            if not line.strip():
                # empty line
                buildingCallSite = False
                # add this call site to list
                if currentCallSite not in callSites:
                    callSites.append(currentCallSite)
                # then init empty new currentCallSite
                currentCallSite = ""
            else:
                # add this line to currentCallSite
                if (':' in line):
                    currentMethod = re.search('(\S+java\S+)', line)
                    if currentMethod:
                        currentCallSite = currentCallSite + currentMethod.group(0)

        if "advice()" in line:
            #print "found advice: " + line
            buildingCallSite = True



print "number of unique call sites: " + str(len(callSites))

i = 0
for currentCallSite in callSites:
    print str(i) + ":" + currentCallSite 
    i = i + 1
