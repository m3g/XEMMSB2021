"""

Given the output of the minimization, this function will generate the input
of the equilibration and production runs

"""
function input_gen(nrep=4, Tₘ=425.0, T₀=300.0; 
                   filesdir="./",
                   processed="./processed.top",
                   topology="./topology.top",
                   minimization_out="./minimization.gro")
   
  λ = [exp((-i/(nrep-1))*log(Tm/T0)) for i in 0:(nrep-1)]
  T = T₀ ./ λ
  
  for i in 0:(nrep-1)
    run(`mkdir -p $i`)
    run(`cp plumed.dat ./$i`)   
    for file in ["nvt", "npt", "prod"]
      open("$file.mdp","r") do input
        open("$i/$file.tmp","w") do output
          for line in eachline(input)
            line = replace(line,"300" => "$(T[i+1])")
            println(output,line)
          end
        end
      end
    end
    # plumed partial-tempering calculation
    # This is equivalent to bash: 
    # % cat $processed > plumed partial_tempering $(λ[i+1]) > $out/$topology 
    run(pipeline("$processed", `plumed partial_tempering $(λ[i+1])`, "$i/$topology"))
  end

end # function input_gen

# call function
input_gen()

