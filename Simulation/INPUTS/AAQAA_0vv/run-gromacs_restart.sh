 #PBS -S /bin/bash
 #PBS -m abe
 #PBS -q route
 #PBS -N NAME
 #PBS -l walltime=480:00:00
 #PBS -l select=10:ncpus=24:ngpus=2:Qlist=Allnodes
 #PBS -V
 #PBS -o RUN/jobout
 #PBS -e RUN/joberr
 #!/bin/bash

 run=RUN 

 cd $PBS_O_WORKDIR

 # nodelist
 cat $PBS_NODEFILE > temp.txt
 uniq temp.txt | awk -F "." '{print $1}' > nodelist.txt
 rm temp.txt

 #module load
 source /etc/profile.d/modules.sh
 module load cmake/cmake-3.15
 module load cuda/cuda-10.1
 module load compiler/gcc-7.4.0
 module load openmpi/openmpi-4.0.5
 module load fftw/fftw-3.3.8

 ## Loading Packmol, plumed, julia1.5 and gromacs_mpi-2019.4
 export PATH=/home/viniciusp/programas/julia-1.5.0/bin:$PATH
 export PATH=/home/viniciusp/programas/plumed-2.5.5/src/lib:$PATH
 export PATH=/home/viniciusp/programas/gromacs-2019.4/bin:$PATH

 ## Loading required libraries (For those programs above)
 export LD_LIBRARY_PATH=/home/viniciusp/programas/plumed-2.5.5/src/lib:$LD_LIBRARY_PATH
 export LD_LIBRARY_PATH=/home/viniciusp/programas/gromacs-2019.4/lib64:$LD_LIBRARY_PATH
 export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
 export PATH=/home/viniciusp/programas/gromacs-2019.4/lib64:$PATH
 export LD_LIBRARY_PATH=/softwares/fftw-3.3.8/lib:$LD_LIBRARY_PATH

 cd $run

 # replicas 
 rep=10

 # number of replicas per node
 nper=1 

 # number of threads for each node
 export OMP_NUM_THREADS=12

 # restarting the simulation
 /softwares/openmpi-4.0.5/bin/mpirun -np $rep --npernode $nper --hostfile nodelist /home/viniciusp/programas/gromacs-2019.4/bin/gmx_mpi mdrun -bonded gpu -nb gpu -pme gpu -s production.tpr -cpi production_prev.cpt -plumed plumed.dat -v -deffnm production -multidir 0 1 2 -replex 400 -hrex -dlb no 
