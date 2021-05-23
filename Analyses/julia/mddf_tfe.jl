using Plots, LaTeXStrings, ComplexMixtures, PDBTools, EasyFit

if (!isdir(ARGS[1])) || (!isdir(ARGS[2])) 
  println("Run with: julia mddf_tfe.jl \$repo \$work")
  exit()
end
repo = ARGS[1]
work = ARGS[2]

# Set solute and solvent
atoms = readPDB("$repo/Simulations/Final/system60.pdb")
protein = select(atoms,"protein")
tfe = select(atoms,"resname TFE")
solute = Selection(protein,nmols=1) 
solvent = Selection(tfe,natomspermol=9) 

# Load previously calculated results
results = ComplexMixtures.load("$work/Simulations/cm_tfe60.json")

# Will use moving averages for more pretty graphs
ma(data) = movingaverage(data,10).x

# Default plot parameters
default(fontfamily="Computer Modern",grid=false,framestyle=:box,linewidth=2)
plot()

# Complete MDDF
plot!(results.d,ma(results.mddf),xlabel="r/Å",ylabel="mddf",label="Total")

# Fluorine atoms
f_contrib = contrib(solvent,results.solvent_atom,
                    select(atoms,"resname TFE and element F"))
plot!(results.d,ma(f_contrib),label="Fluorine")

# Carbon atoms
c_contrib = contrib(solvent,results.solvent_atom,
                    select(atoms,"resname TFE and element C"))
plot!(results.d,ma(c_contrib),label="Carbon")

# Aliphatic hydrogens
ha_contrib = contrib(solvent,results.solvent_atom,
                     select(atoms,"name H21 or name H22"))
plot!(results.d,ma(ha_contrib),label="Aliphatic H")

# Hydroxyl hydrogen
hy_contrib = contrib(solvent,results.solvent_atom,
                     select(atoms,"resname TFE and name H"))
plot!(results.d,ma(hy_contrib),label="Hydroxyl H")

# Hydroxyl oxygen
ho_contrib = contrib(solvent,results.solvent_atom,
                     select(atoms,"resname TFE and name O"))
plot!(results.d,ma(ho_contrib),label="Hydroxyl O")

# draw an horizontal line at y=1
hline!([1],color=:gray,linestyle=:dash,label="")

# Save figure
savefig("$work/Simulations/mddf_tfe.pdf")
println("Wrote file: mddf_tfe.pdf")

