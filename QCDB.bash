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

echo "sbatch QCBC.bash"
export OMP_NUM_THREADS=32

export MKL_NUM_THREADS=32

source $HOME/jupyter_py2/bin/activate
module load openmpi/2.1.1
export PYTHONPATH=/cvmfs/soft.computecanada.ca/easybuild/software/2017/avx2/MPI/intel2016.4/openmpi2.1/psi4/1.1/lib/
export PSI_SCRATCH=$HOME/scratch
module load psi4/1.1
source $HOME/jupyter_py2/bin/activate




module load gaussian/g16.b01

METHOD="HF MP2 MP3 B3LYP WB97XD"
BASIS="STO-3G 3-21G 6-31G 6-311++G(3df,3pd) aug-cc-pvdz aug-cc-pvtz aug-cc-pvqz"

n=1
MAX=1000000
function looklist {
while [ $(head -n 1 /home/dion/QCDB/lists.txt) != "" ] ; do
	n=$(head -n 1 /home/dion/QCDB/lists.txt)
	mkdir -p $n
	cd $n
	python /home/dion/QCDB/bin/get_XYZ $n > XYZ.txt

        if [ $? == 0 ] ; then
                mkdir -p GAUSSIAN
                cd GAUSSIAN
                bash /home/dion/QCDB/bin/launch_gaussian
                cd ..
        fi
	cd ..
done
tail -n $(echo "$(cat /home/dion/QCDB/lists.txt |wc -l)-1" | bc -l) /home/dion/QCDB/lists.txt > /home/dion/QCDB/lists.txt.tmp
mv /home/dion/QCDB/lists.txt.tmp /home/dion/QCDB/lists.txt
}

while [ "$n" -lt "$MAX" ] ; do
	looklist
	mkdir -p $n
	cd $n 
	python /home/dion/QCDB/bin/get_XYZ $n > XYZ.txt
	if [ $? == 0 ] ; then
		mkdir -p GAUSSIAN
		cd GAUSSIAN
		bash /home/dion/QCDB/bin/launch_gaussian
		cd ..
	fi
	cd ..
	let n=$n+1
done
