 #PBS -S /bin/bash
 #PBS -m abe
 #PBS -q route
 #PBS -N A-0vv
 #PBS -l walltime=480:00:00
 #PBS -l select=5:ncpus=20:ngpus=2:Qlist=Allnodes
 #PBS -V
 #PBS -o /home/ander/doutorado/aaqaa/AAQAA_0vv/jobout
 #PBS -e /home/ander/doutorado/aaqaa/AAQAA_0vv/joberr
 #!/bin/bash

 run=/home/ander/doutorado/aaqaa/AAQAA_0vv

 cd $PBS_O_WORKDIR

 # nodelist
 cat $PBS_NODEFILE > temp.txt
 uniq temp.txt | awk -F "." '{print $1}' > nodelist.txt
 rm temp.txt

 #module load
 source /etc/profile.d/modules.sh
 module load cuda/cuda-10.1 
 module load openmpi/openmpi-3.1.2

 export PATH=$PATH:/softwares/fftw-3.3.8/bin
 export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/softwares/fftw-3.3.8/lib
 export MANPATH=$MANPATH:/softwares/fftw-3.3.8/share/man/man1

 ## Loading Packmol, plumed, julia1.5 and gromacs_mpi-2019.4
 export PATH=/home/ander/programas/julia-1.5.0/bin:$PATH
 export PATH=/home/ander/programas/plumed-2.5.5/src/lib:$PATH
 export PATH=/home/ander/programas/gromacs-2019.4/bin:$PATH

 ## Loading required libraries (For those programs above)
 export LD_LIBRARY_PATH=/home/ander/programas/plumed-2.5.5/src/lib:$LD_LIBRARY_PATH
 export LD_LIBRARY_PATH=/home/ander/programas/gromacs-2019.4/lib64:$LD_LIBRARY_PATH
 export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
 export PATH=/home/ander/programas/gromacs-2019.4/lib64:$PATH

# export PATH=/softwares/openmpi-3.1.2/bin:$PATH
# export LD_LIBRARY_PATH=/softwares/openmpi-3.1.2/lib:$LD_LIBRARY_PATH

# LD_LIBRARY_PATH=/usr/lib64/:$LD_LIBRARY_PATH
# export LD_LIBRARY_PATH

 cd $run


 # minimization
 gmx_mpi mdrun -s minimization.tpr -v -deffnm minimization
 echo {0..9} | xargs -n 1 cp *.itp 

 # replicas 
 rep=10

 # number of threads for each node
 export OMP_NUM_THREADS=10

 # NVT inputs
 julia gen_inputs.jl 

 # NVT simulation and NPT inputs
 /softwares/openmpi-3.1.2/bin/mpirun -np $rep --npernode 2 --hostfile nodelist.txt /home/ander/programas/gromacs-2019.4/bin/gmx_mpi mdrun -pin on -nb gpu -pme gpu -s canonical.tpr -v -deffnm canonical -multidir 0 1 2 3 4 5 6 7 8 9 

 julia npt_inputs.jl

 # NPT simulations and prod inuts
 /softwares/openmpi-3.1.2/bin/mpirun -np $rep --npernode 2 --hostfile nodelist.txt /home/ander/programas/gromacs-2019.4/bin/gmx_mpi mdrun -pin on -nb gpu -pme gpu -s isobaric.tpr -v -deffnm isobaric -multidir 0 1 2 3 4 5 6 7 8 9

 julia prod_files.jl

 #production simulation
 /softwares/openmpi-3.1.2/bin/mpirun -np $rep --npernode 2 --hostfile nodelist.txt /home/ander/programas/gromacs-2019.4/bin/gmx_mpi mdrun -pin on -nb gpu -pme gpu -plumed plumed.dat -s production.tpr -v -deffnm production -multidir 0 1 2 3 4 5 6 7 8 9 -replex 400 -hrex -dlb no 


