# Load packages
using PDBTools, ComplexMixtures 

# Load PDB file of the system
atoms = readPDB("../system.pdb")

# Select the protein and the solvents
protein = select(atoms,"protein")
tfe = select(atoms,"resname TFE")

# Setup solute (1 protein)
solute = Selection(protein,nmols=1)

# Setup solvent (number of atoms of TFE molecule = 9)
solvent = Selection(tfe,natomspermol=9)

# Setup the Trajectory structure
trajectory = Trajectory("production.xtc",solute,solvent)

# Options (dbulk: distance above which the solute does not
# affect the structure of the solvent)
options = Options(dbulk=10)

# Run the calculation and get results
results = mddf(trajectory,options)

# Save the reults to recover them later if required
save(results,"./cm-tfe.json")

