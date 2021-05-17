  function Production()
    nrep = parse(Int64,readline())
    for i in 0:(nrep - 1) 
      run(`gmx_mpi grompp -f $i/prod$i.mdp -p $i/topol$i.top -c $i/isobaric.gro  -o $i/production.tpr -maxwarn 10`)   # maxwarn só serve para o comando funcionar    
    end                                                                                                               # todos os avisos problemáticos já foram resolvidos
  end

 Production()
