# Load packages
using PDBTools, ComplexMixtures 

# Load PDB file of the system
atoms = readPDB("system.pdb")

# Select the protein and the solvents
protein = select(atoms,"protein")
water = select(atoms,"resname SOL")

# Setup solute
solute = ComplexMixtures.Selection(protein,nmols=1)

# Setup solvent
solvent = ComplexMixtures.Selection(water,natomspermol=4)                 # natomspermol = numbers of atoms of water.

# Setup the Trajectory structure
trajectory = ComplexMixtures.Trajectory("production-center.xtc",solute,solvent)

# Options
options = ComplexMixtures.Options(dbulk=20)

# Run the calculation and get results
results = ComplexMixtures.mddf(trajectory,options)

# Save the reults to recover them later if required
ComplexMixtures.save(results,"./results-water-20.json")

