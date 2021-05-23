using Plots, LaTeXStrings, ComplexMixtures, PDBTools, EasyFit

if (!isdir(ARGS[1])) || (!isdir(ARGS[2])) 
  println("Run with: julia mddf_water.jl \$repo \$work")
  exit()
end
repo = ARGS[1]
work = ARGS[2]

# Will use moving averages for more pretty graphs
ma(data) = movingaverage(data,10).x

#
# Set solute and solvent - pure water
#
atoms = readPDB("$repo/Simulations/Final/system0.pdb")
protein = select(atoms,"protein")
water = select(atoms,"resname SOL and not name MW")
solute = Selection(protein,nmols=1) 
solvent = Selection(water,natomspermol=3) 

# Load previously calculated results
results = ComplexMixtures.load("$work/Simulations/cm_water0.json")

# Default plot parameters
default(fontfamily="Computer Modern",grid=false,framestyle=:box,linewidth=2)
plot(layout=(1,2))

sp=1
# Complete MDDF
plot!(results.d,ma(results.mddf),
      xlabel="r/Å",ylabel="mddf",label="Total",subplot=sp)

# Hydrogen atoms
h_contrib = contrib(solvent,results.solvent_atom,
                    select(atoms,"resname SOL and element H"))
plot!(results.d,ma(h_contrib),label="Hydrogens",subplot=sp)

# Oxygen atoms
o_contrib = contrib(solvent,results.solvent_atom,
                    select(atoms,"resname SOL and element O"))
plot!(results.d,ma(o_contrib),label="Oxygen",subplot=sp)

# draw an horizontal line at y=1
hline!([1],color=:gray,linestyle=:dash,label="",subplot=sp)

#
# Set solute and solvent - water/TFE
#
atoms = readPDB("$repo/Simulations/Final/system60.pdb")
protein = select(atoms,"protein")
water = select(atoms,"resname SOL and not name MW")
solute = Selection(protein,nmols=1) 
solvent = Selection(water,natomspermol=3) 

# Load previously calculated results
results = ComplexMixtures.load("$work/Simulations/cm_water60.json")

sp=2
# Complete MDDF
plot!(results.d,ma(results.mddf),
      xlabel="r/Å",ylabel="mddf",label="Total",subplot=sp)

# Hydrogen atoms
h_contrib = contrib(solvent,results.solvent_atom,
                    select(atoms,"resname SOL and element H"))
plot!(results.d,ma(h_contrib),label="Hydrogens",subplot=sp)

# Oxygen atoms
o_contrib = contrib(solvent,results.solvent_atom,
                    select(atoms,"resname SOL and element O"))
plot!(results.d,ma(o_contrib),label="Oxygen",subplot=sp)

# draw an horizontal line at y=1
hline!([1],color=:gray,linestyle=:dash,label="",subplot=sp)

# Save figure
savefig("$work/Simulations/mddf_water.pdf")
println("Wrote file: mddf_water.pdf")

