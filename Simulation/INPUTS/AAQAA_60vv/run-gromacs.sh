 #PBS -S /bin/bash
 #PBS -m abe
 #PBS -q route
 #PBS -N NAME
 #PBS -l walltime=480:00:00
 #PBS -l select=5:ncpus=24:ngpus=2:Qlist=Allnodes
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


 # minimization
 gmx_mpi mdrun -s minimization.tpr -v -deffnm minimization
 echo {0..9} | xargs -n 1 cp *.itp 

 # replicas 
 rep=10

 # number of threads for each node
 export OMP_NUM_THREADS=12

 nper=2

 # NVT inputs
 echo $rep | julia gen_inputs.jl 

 # NVT simulation and NPT inputs
 /softwares/openmpi-4.0.5/bin/mpirun -np $rep --npernode $nper --hostfile nodelist.txt /home/viniciusp/programas/gromacs-2019.4/bin/gmx_mpi mdrun -bonded gpu -nb gpu -pme gpu -s canonical.tpr -v -deffnm canonical -multidir 0 1 2 3 4 5 6 7 8 9 

 echo $rep | julia npt_inputs.jl

 # NPT simulations and prod inuts
 /softwares/openmpi-4.0.5/bin/mpirun -np $rep --npernode $nper --hostfile nodelist.txt /home/viniciusp/programas/gromacs-2019.4/bin/gmx_mpi mdrun -bonded gpu -nb gpu -pme gpu -s isobaric.tpr -v -deffnm isobaric -multidir 0 1 2 3 4 5 6 7 8 9 

 echo $rep | julia prod_files.jl

 #production simulation
 /softwares/openmpi-4.0.5/bin/mpirun -np $rep --npernode $nper --hostfile nodelist.txt /home/viniciusp/programas/gromacs-2019.4/bin/gmx_mpi mdrun -bonded gpu -nb gpu -pme gpu -plumed plumed.dat -s production.tpr -v -deffnm production -multidir 0 1 2 3 4 5 6 7 8 9 -replex 400 -hrex -dlb no 


