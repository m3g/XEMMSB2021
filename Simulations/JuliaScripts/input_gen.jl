"""

Given the output of the minimization, this function will generate the input
of the equilibration and production runs

"""
function input_gen(nrep=4, Tₘ=425.0, T₀=300.0; 
                   filesdir="./",
                   processed="$filesdir/processed.top",
                   topology="$filesdir/topology.top",
                   minimization_out="$filesdir/minimization.gro")
   
  λ = [exp((-i/(nrep-1))*log(Tm/T0)) for i in 0:(nrep-1)]
  T = T₀ ./ λ
  
  for i in 0:(nrep-1)
    run(`mkdir -p $i`)
    run(`cp plumed.dat ./$i`)   
    for file in ["nvt", "npt", "prod"]
      open("$filesdir/$file.mdp","r") do input
        open("$i/$file.tmp","w") do output
          for line in eachline(input)
            line = replace(line,"REFT" => "$(T[i+1])")
            println(output,line)
          end
        end
      end
    end
         
    # plumed partial-tempering calculation
    # This is equivalent to bash: 
    # % cat $processed > plumed partial_tempering $(λ[i+1]) > $out/$topology 
    run(pipeline("$processed", `plumed partial_tempering $(λ[i+1])`, "$i/$topology"))

    # run Gromacs
    run(`gmx_mpi grompp -f $i/nvt.mdp -c $minimization_out -p $i/$topology $i/canonical.tpr -maxwarn 3`)
  end

end # function input_gen

