#! /bin/bash
#SBATCH -t 3-00:00
#SBATCH -c 32
#SBATCH --mem=0
#SBATCH --account=def-fdion
#SBATCH -J QCDB_main
# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL
# send mail to this address
#SBATCH --mail-user=meitnerium109@gmail.com


source QCDB.config
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
#module load psi4/1.1
source $HOME/jupyter_py2/bin/activate



if [ $LOGICIEL == "GAUSSIAN" ]; then
  module load gaussian/g16.b01
elif [ $LOGICIEL == "GAMESS" ] ; then
  module load gamess-us/20170420-R1
fi


METHOD="HF MP2 MP3 B3LYP WB97XD"
BASIS="STO-3G 3-21G 6-31G 6-311++G(3df,3pd) aug-cc-pvdz aug-cc-pvtz aug-cc-pvqz"

n=1
MAX=1000000
function looklist {
while [ $(cat ${QCDBREP}/lists.txt | wc -l) -gt "0" ] ; do
	n=$(head -n 1 ${QCDBREP}/lists.txt)
	echo "after n in ${QCDBREP}/lists.txtt"
	mkdir -p $n
	cd $n
	python ${QCDBREP}/bin/get_XYZ $n > XYZ.txt

        if [ $? == "0" ] && [ $LOGICIEL == "GAUSSIAN" ] ; then
                mkdir -p GAUSSIAN
                cd GAUSSIAN
                bash ${QCDBREP}/bin/launch_gaussian -nproc $NPROC -mem $MEM

                cd ..
	elif [ $LOGICIEL == "GAMESS" ] ; then
		mkdir -p GAMESS
		cd GAMESS
		echo "In GAMESS rep"
		pwd
		bash ${QCDBREP}/bin/launch_gamess -nproc $NPROC -mem $MEM
		cd ..
        fi
	cd ..
	tail -n $(echo "$(cat ${QCDBREP}/lists.txt | wc -l)-1" | bc -l) ${QCDBREP}/lists.txt > ${QCDBREP}/lists.txt.tmp
	mv ${QCDBREP}/lists.txt.tmp ${QCDBREP}/QCDB/lists.txt
done
}

while [ "$n" -lt "$MAX" ] ; do
  looklist
  mkdir -p $n
  cd $n 
  python ${QCDBREP}/bin/get_XYZ $n > XYZ.txt
  if [ $? == 0 ] && [ $LOGICIEL == "GAUSSIAN" ] ; then
                mkdir -p GAUSSIAN
                cd GAUSSIAN
                bash ${QCDBREP}/bin/launch_gaussian -nproc $NPROC -mem $MEM
                cd ..
        elif [ $LOGICIEL == "GAMESS" ] ; then
                mkdir -p GAMESS
                cd GAMESS
                echo "In GAMESS rep"
                pwd
                bash ${QCDBREP}/QCDB/bin/launch_gamess -nproc $NPROC -mem $MEM
                cd ..
  fi
  cd ..
  let n=$n+1
done
