# Load packages
using PDBTools, ComplexMixtures 

# Repository dir
if (! isdir(ARGS[1])) || (! isdir(ARGS[2]))
  println("Run with: cm_water60.jl \$repo \$work")
  exit()
end
repo = ARGS[1]
work = ARGS[2]

# Load PDB file of the system
atoms = readPDB("$repo/Simulations/Final/system60.pdb")

# Select the protein and the solvents
protein = select(atoms,"protein")
water = select(system,"resname SOL and not name MW")

# Setup solute
solute = Selection(protein,nmols=1)

# Setup solvent
solvent = Selection(water,natomspermol=3)

# Setup the Trajectory structure
trajectory = Trajectory("production60.xtc",solute,solvent)

# Options
options = Options(dbulk=10)

# Run the calculation and get results
results = mddf(trajectory,options)

# Save the reults to recover them later if required
save(results,"$work/cm_water60.json")

