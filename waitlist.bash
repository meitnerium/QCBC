#! /bin/bash
#SBATCH -t 0-08:00
#SBATCH -c 32
#SBATCH --mem=0
#SBATCH --account=def-fdion
#SBATCH -J QCDB
# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=meitnerium109@gmail.com


NPROC=32
MEM=100GB
while [ $1 ] ; do
  if [ $1 == "-nproc" ] ; then
        NPROC=$2
        shift
        shift
  elif [ $1 == "-mem" ] ; then
          MEM=$2
        shift
        shift
  fi
done



export OMP_NUM_THREADS=$NPROC

export MKL_NUM_THREADS=$NPROC

source $HOME/jupyter_py2/bin/activate
module load openmpi/2.1.1
export PYTHONPATH=/cvmfs/soft.computecanada.ca/easybuild/software/2017/avx2/MPI/intel2016.4/openmpi2.1/psi4/1.1/lib/
export PSI_SCRATCH=$HOME/scratch
module load psi4/1.1
source $HOME/jupyter_py2/bin/activate




module load gaussian/g16.b01

$(head -n 1 /home/dion/QCDB/waitlist.txt)
sed -i "s/MEM2CHANGE/$MEM/" *.gjf
sed -i "s/NPROC2CHANGE/$NPROC/" *.gjf
$(head -n 2 /home/dion/QCDB/waitlist.txt | tail -n 1)
$(head -n 3 /home/dion/QCDB/waitlist.txt | tail -n 1)
NL=$(cat /home/dion/QCDB/waitlist.txt | wc -l) 

tail -n $(echo "$NL-3" | bc -l) /home/dion/QCDB/waitlist.txt > /home/dion/QCDB/waitlist.txt.tmp
mv /home/dion/QCDB/waitlist.txt.tmp /home/dion/QCDB/waitlist.txt