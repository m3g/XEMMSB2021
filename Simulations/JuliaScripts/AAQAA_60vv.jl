#
# run with julia AAQAA_60vv.jl 
#

using PackmolInputCreator

# Directory where this script is hosted
script_dir = @__DIR__

# Density as a function of molar fraction of TFE
#   FE mol frac  Density (g/mL) ref: https://doi.org/10.1023/A:1005147318013
ρ = [ 0.00       0.99707       
      0.00130    0.99931       
      0.00178    1.00013       
      0.00264    1.00161       
      0.00318    1.00253       
      0.00587    1.00711       
      0.00792    1.01061       
      0.00841    1.01145       
      0.01362    1.02009       
      0.01550    1.02331       
      0.01966    1.03032       
      0.02837    1.04416       
      0.04430    1.06827       
      0.06485    1.09668       
      0.07171    1.10545       
      0.08744    1.12449       
      0.1071     1.14364       
      0.1526     1.18115       
      0.2126     1.22017       
      0.2960     1.26039       
      0.4245     1.30204       
      0.6088     1.33868       
      0.7820     1.36029       
      0.9451     1.37873       
      1.0000     1.38217  ]

# What we want
concentration = 95.77 #%vv

# Find to what molar fraction this volume fraction corresponts
x = find_x(concentration, 100.4, 1.38217, ρ)
println("Molar fraction = $x")

# Iterpolate to get density given molar fraction
density = PackmolInputCreator.interpolate(x,ρ)
println("Density = $density")

data_dir="$script_dir/../InputData"
pdbfile = "$data_dir/PDB/AAQAA.pdb"
solvent_file = "$data_dir/PDB/tfe.pdb"
water_file = "$data_dir/PDB/tip4p2005.pdb"
box_side = 56.

write_input(pdbfile, solvent_file, concentration, box_side,
            water_file=water_file,
            density=density,
            density_pure_solvent=1.38217,
            box_file="box.inp",cunit="%vv")



