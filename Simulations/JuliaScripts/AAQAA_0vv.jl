#
# run with julia AAQAA_0vv.jl 
#

# Directory where this script is hosted
script_dir = @__DIR__

using PackmolInputCreator

data_dir="$script_dir/../InputData"

pdbfile = "$data_dir/PDB/AAQAA.pdb"
solvent_file = "$data_dir/PDB/tfe.pdb"
water_file = "$data_dir/PDB/tip4p2005.pdb"
concentration = 0
box_side = 56.

write_input(
  pdbfile, solvent_file, concentration, box_side,
  packmol_input="box.inp",
  packmol_output="system.pdb",
  water_file=water_file
)
    


