# Load packages
using PDBTools, ComplexMixtures 

# Repository dir
if (! isdir(ARGS[1])) || (! isdir(ARGS[2]))
  println("Run with: cm_tfe.jl \$repo \$work") 
  exit()
end

# Load PDB file of the system
atoms = readPDB("$repo/Simulations/Final/system60.pdb")

# Select the protein and the solvents
protein = select(atoms,"protein")
tfe = select(atoms,"resname TFE")

# Setup solute (1 protein)
solute = Selection(protein,nmols=1)

# Setup solvent (number of atoms of TFE molecule = 9)
solvent = Selection(tfe,natomspermol=9)

# Setup the Trajectory structure
trajectory = Trajectory("$repo/Simulations/Final/production60.xtc",solute,solvent)

# Options (dbulk: distance above which the solute does not
# affect the structure of the solvent)
options = Options(dbulk=10)

# Run the calculation and get results
results = mddf(trajectory,options)

# Save the reults to recover them later if required
save(results,"$work/cm_tfe60.json")

