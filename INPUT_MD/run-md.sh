  XEMMSB_dir=$1
 
 if [ -z "$XEMMSB_dir" ]; then
   echo "Run with: ./install.sh /home/user/INPUT/AAQAA"
   exit
 fi
 
 if [[ ! -d "$XEMMSB_dir" ]]; then
     echo "$XEMMSB_dir does not exist. Create it first. "
     exit
 fi

 cd $XEMMSB_dir
   
 # minimization
 gmx_mpi mdrun -s minimization.tpr -v -deffnm minimization
 echo {0..3} | xargs -n 1 cp *.itp 

 # replicas 
 rep=4

 # Inputs para simulacao NVT
 echo $rep | julia gen_inputs.jl 

 # NVT simulation and NPT inputs
 mpirun -np $rep gmx_mpi mdrun -s canonical.tpr -v -deffnm canonical -multidir 0 1 2 3  

 echo $rep | julia npt_inputs.jl

 # NPT simulations and prod inuts
 mpirun -np $rep gmx_mpi mdrun -s isobaric.tpr -v -deffnm isobaric -multidir 0 1 2 3 

 echo $rep | julia prod_files.jl

 #production simulation
 mpirun -np $rep gmx_mpi mdrun -plumed plumed.dat -s production.tpr -v -deffnm production -multidir 0 1 2 3  -replex 400 -hrex -dlb no 

