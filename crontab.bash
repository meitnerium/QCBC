#!  /cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09/bin/bash

if [ $(squeue -u dion | grep -c "PD") == "0" ] && [ $(cat /scratch/dion/QCDB/waitlist.txt | wc -l) -gt "0" ] ; then
  sbatch /scratch/dion/QCDB/bin/launch_waitlist.submit
fi
if [ $(squeue -u dion | grep -c "QCDB_main") == "0" ] ; then
  cd /scratch/dion/QCDB/
  sbatch QCDB.bash
fi
