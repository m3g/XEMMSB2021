#
# run with julia AAQAA_60vv.jl 
#

# Directory where this script is hosted
script_dir = @__DIR__

include("$script_dir/CreateInputs.jl")
using .CreateInputs 

data_dir="$script_dir/../InputData"

pdbfile = "$data_dir/PDB/AAQAA.pdb"
solvent_file = "$data_dir/PDB/tfe.pdb"
water_file = "$data_dir/PDB/tip4p2005.pdb"
concentration = 6.0
box_size = 28.
topology_base = "$data_dir/Topology/topology_base.top"

CreateInputs.box(pdbfile, solvent_file, concentration, box_size,
                 box_file="box.inp",
                 topology_base=topology_base,
                 topology_out="topology.top",
                 water_file=water_file)
    


