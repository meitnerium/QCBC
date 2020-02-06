import csv
import cif2cell
#import str
import numpy as np
import re
import os
import urllib
import requests
#from crystals import Crystal
import CifFile
import subprocess
from cif2cell.utils import *
from cif2cell.uctools import *
#from cif2cell.ESPInterfaces import *
from cif2cell.elementdata import *
from six.moves import range

#from __future__ import division
#from __future__ import absolute_import
#from __future__ import print_function
import os
import sys
import string
import copy
from math import *
from datetime import datetime
from optparse import OptionParser, OptionGroup
import warnings
import CifFile
import subprocess
from cif2cell.utils import *
from cif2cell.uctools import *
from cif2cell.ESPInterfaces import *
from cif2cell.elementdata import *
from six.moves import range
import COD 


import operator        
nmax=20
n=1

with open('COD-selection.csv') as csvfile:
   spamreader = csv.reader(csvfile, delimiter=',', quotechar='|')
   #sortedlist = sorted(spamreader, key=operator.itemgetter(13), reverse=False)
   for row in spamreader:
      print('NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN')
      print(n)
      if n > nmax:
         sys.exit(0)
      f = open('done.txt','a')
      value=re.sub("['\"]","",row[0])
      #f.write(row[0]+" "+row[13])
      f.write(row[0])
      f.close()
      #print(value)
      #print(row[0])
      try:
         intval=np.int(value)
      except ValueError:
         print(ValueError)
         continue
      print(intval)
      path=str(intval)
      try:
         os.mkdir(path)
      except OSError:
         print ("Creation of the directory %s failed" % path)
      else:
         print ("Successfully created the directory %s " % path)
         os.chdir(path)
         r = requests.get("http://www.crystallography.net/cod/"+path+".cif")
         open(path+".cif", 'wb').write(r.content)
         #import subprocess
         #subprocess.run(["cif2cell", path+".cif", "--pwscf-cartesian-positions", "-p", "quantum-espresso"])
         COD.cif2cellfunc(path+".cif")
         #cif_grammar = '1.1'
         #cf = CifFile.ReadCif(path+".cif",grammar=cif_grammar)

         #docstring = ""
         #cd = CellData()
         #cd.getFromCIF(cf)
         #kresolution=0.2
         #pwscfinput = PWSCFFile(cd, docstring,kresolution=kresolution)
         #print(pwscfinput)
##################################

# Output for PWSCF (Quantum Espresso)
#if outputprogram == 'pwscf':
#    docstring = StandardDocstring()
#    pwscfinput = PWSCFFile(cd, docstring,kresolution=kresolution)
#    if options.setupall:
#        pwscfinput.setupall = True
#        pwscfinput.kresolution = kresolution
#    if options.pwscfpseudostring:
#        pwscfinput.pseudostring = options.pwscfpseudostring
#    if options.pwscfcart:
#        pwscfinput.cartesian = True
#    if options.pwscfcartvects:
#        pwscfinput.cartesianlatvects = True
#    if options.pwscfcartpos:
#        pwscfinput.cartesianpositions = True
#    if options.pwscfalatunits:
#        pwscfinput.scaledcartesianpositions = True
#    if options.pwscfatomicunits:
#        pwscfinput.unit = "bohr"
#    f = open(outputfile, outmode)
#    f.write(str(pwscfinput))
#    f.close()

################################





         f = open('scf.sh','w')
         f.write("#! /bin/bash\n")
         f.write("#PBS -A cjt-923-aa\n")
         f.write("#PBS -N QE_1000303\n")
         f.write("#PBS -l nodes=1:ppn=52\n")
         #f.write("#PBS -l walltime=48:00:00\n")
         f.write("\n")
         f.write("cd \"${PBS_O_WORKDIR}\"\n")
         f.write("export OMP_NUM_THREADS=1\n")
         #f.write("module load apps/quantum-espresso/5.4.0\n")
         f.write("module load mpi/openmpi-x86_64\n")
         f.write("time mpirun -np 52 /home/software/QE/qe-6.3/bin/pw.x < scf.in > scf.out\n")
         f.write("\n")
         f.close()
         import subprocess
         subprocess.run(["sbatch", "scf.sh"])
         
         
         os.chdir('..')
         n=n+1







# cif2cell  1000315.cif --pwscf-cartesian-positions -p quantum-espresso




      #   if str.isdigit(row[0]):
      #      print(row[0])
      #print(row[0].split(",")[0])
      #print(', '.join(row))

