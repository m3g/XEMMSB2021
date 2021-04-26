 function NPT_calc()
   nrep = parse(Int64,readline())
   for i in 0:(nrep - 1) 
     run(`gmx_mpi grompp -f $i/npt$i.mdp -p $i/topol$i.top -c $i/canonical.gro  -o $i/isobaric.tpr -maxwarn 3`)       
   end
 end

  NPT_calc()
