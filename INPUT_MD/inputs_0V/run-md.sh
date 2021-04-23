
 # minimization
 gmx_mpi mdrun -s minimization.tpr -v -deffnm minimization
 echo {0..3} | xargs -n 1 cp *.itp 

 # replicas 
 rep=4

 # NVT inputs
 echo $rep | julia gen_inputs.jl 

 # NVT simulation and NPT inputs
 mpirun -np $rep gmx_mpi mdrun -s canonical.tpr -v -deffnm canonical -multidir 0 1 2 3  

 echo $rep | julia npt_inputs.jl

 # NPT simulations and prod inuts
 mpirun -np $rep gmx_mpi mdrun -s isobaric.tpr -v -deffnm isobaric -multidir 0 1 2 3 

 echo $rep | julia prod_files.jl

 #production simulation
 mpirun -np $rep gmx_mpi mdrun -plumed plumed.dat -s production.tpr -v -deffnm production -multidir 0 1 2 3  -replex 400 -hrex -dlb no 


