# Load packages
using PDBTools, ComplexMixtures 

# Load PDB file of the system
atoms = readPDB("system.pdb")

# Select the protein and the solvents
protein = select(atoms,"protein")
tfe = select(atoms,"resname TFE")

# Setup solute
solute = ComplexMixtures.Selection(protein,nmols=1)

# Setup solvent
solvent = ComplexMixtures.Selection(tfe,natomspermol=9)                 # natomspermol = numbers of atoms of tfe.

# Setup the Trajectory structure
trajectory = ComplexMixtures.Trajectory("production-center.xtc",solute,solvent)

# Options
options = ComplexMixtures.Options(dbulk=20)

# Run the calculation and get results
results = ComplexMixtures.mddf(trajectory,options)

# Save the reults to recover them later if required
ComplexMixtures.save(results,"./results-tfe-20.json")


