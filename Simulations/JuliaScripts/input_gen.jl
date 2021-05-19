#
#
#
Tm=425.0 
T₀=300.0 
λ = [exp((-i/3)*log(Tm/T0)) for i in 0:3]
for i in 0:3
  # plumed partial-tempering calculation
  # This is equivalent to bash: 
  # % cat $processed > plumed partial_tempering $(λ[i+1]) > $out/$topology 
  run(pipeline("./processed_.top", `plumed partial_tempering $(λ[i+1])`, "./$i/topology.top"))
end
