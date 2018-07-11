#!  /cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09/bin/bash

if [ $(squeue -u dion | grep -c "PD") == "0" ] && [ $(cat /home/dion/QCDB/waitlist.txt | wc -l) -gt "0" ] ; then
  sbatch /home/dion/QCDB/bin/launch_waitlist.submit
fi
