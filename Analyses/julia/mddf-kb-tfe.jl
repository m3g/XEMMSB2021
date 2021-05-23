using Plots, LaTeXStrings, ComplexMixtures, PDBTools, EasyFit

if (!isdir(ARGS[1])) || (!isdir(ARGS[2])) 
  println("Run with: julia mddf_kb.jl \$repo \$work")
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

# Default plot parameters
default(fontfamily="Computer Modern",grid=false,framestyle=:box,linewidth=2)

# Complete MDDF
plot(results.d,movingaverage(results.mddf,10),xlabel="r/Å",ylabel="mddf",label="Total")

# Fluorine atoms
f_contrib = contrib(solvent,results.solvent_atom,
                    select(atoms,"resname TFE and element F"))
plot!(results.d,movingaverage(f_contrib,10),label="Fluorine")

# Carbon atoms
c_contrib = contrib(solvent,results.solvent_atom,
                    select(atoms,"resname TFE and element C"))
plot!(results.d,movingaverage(c_contrib,10),label="Carbon")

# Aliphatic hydrogens
ha_contrib = contrib(solvent,results.solvent_atom,
                     select(atoms,"name H21 or name H22"))
plot!(results.d,movingaverage(ha_contrib,10),label="Aliphatic H")

# Hydroxyl hydrogen
hy_contrib = contrib(solvent,results.solvent_atom,
                     select(atoms,"resname TFE and name H"))
plot!(results.d,movingaverage(hy_contrib,10),label="Hydroxyl H")

# Hydroxyl oxygen
ho_contrib = contrib(solvent,results.solvent_atom,
                     select(atoms,"resname TFE and name O"))
plot!(results.d,movingaverage(hy_contrib,10),label="Hydroxyl O")

# Save figure
savefig("$work/Simulations/mddf-tfe.pdf")

# KB-integral
#plot(results.d,results.kb/1000,xlabel=L"\mathrm{r} / \mathrm{\AA}", ylabel=L"{G_{pc}} \ (r) / \mathrm{L\ mol^{-1}}",#label=false,framestyle=:box,c=:navyblue,dpi=300,xtickfontsize=18,ytickfontsize=18,xguidefontsize=18,yguidefontsize=18,#legendfontsize=18,lw=3,minorticks=Integer)

# Save figure
#savefig("./kb-integral-tfe.png")

