# Load packages
using PDBTools, ComplexMixtures 

# Load PDB file of the system
atoms = readPDB("system.pdb")

# Select the protein and the solvents
protein = select(atoms,"protein")
water = select(system,"resname SOL and not name MW")

# Setup solute
solute = Selection(protein,nmols=1)

# Setup solvent
solvent = Selection(water,natomspermol=3)

# Setup the Trajectory structure
trajectory = Trajectory("production.xtc",solute,solvent)

# Options
options = Options(dbulk=10)

# Run the calculation and get results
results = mddf(trajectory,options)

# Save the reults to recover them later if required
save(results,"./cm_water.json")

