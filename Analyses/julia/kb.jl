using Plots, Plots.Measures, LaTeXStrings, ComplexMixtures

if (!isdir(ARGS[1])) || (!isdir(ARGS[2])) 
  println("Run with: julia mddf_tfe.jl \$repo \$work")
  exit()
end
repo = ARGS[1]
work = ARGS[2]

# Default plot parameters
default(fontfamily="Computer Modern",framestyle=:box,linewidth=2)
plot(layout=(1,3))

# Load previously calculated results: pure water
results = ComplexMixtures.load("$work/Simulations/cm_water0.json")
sp=1
plot!(title="pure Water",subplot=sp)
plot!(results.d,results.kb/1000,xlabel="r/Å",ylabel=L"\textrm{KB / L }\mathrm{mol^{-1}}",label="",subplot=sp)

# Load previously calculated results: TFE/water
results = ComplexMixtures.load("$work/Simulations/cm_water60.json")
sp=2
plot!(title="Water in Water/TFE",subplot=sp)
plot!(results.d,results.kb/1000,xlabel="r/Å",label="",subplot=sp)

# Load previously calculated results: TFE/water
results = ComplexMixtures.load("$work/Simulations/cm_tfe60.json")
sp=3
plot!(title="TFE in Water/TFE",subplot=sp)
plot!(results.d,results.kb/1000,xlabel="r/Å",label="",subplot=sp)

plot!(ylim=[-2.0,0],xlim=[0,10])
plot!(leftmargin=5mm,bottommargin=5mm)

# Save figure
plot!(size=(900,400))
savefig("$work/Simulations/kb.pdf")
println("Wrote file: kb.pdf")

