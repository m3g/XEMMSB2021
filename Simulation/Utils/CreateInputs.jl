#
# This script read pdb files and write inp inputs for using in packmol, and
# the topology for gromacs
#
module CreateInputs

using PDBTools

# Volume of the box (L)
vol_box(a,b,c) = a*b*c*1e-27;

# Volume of the protein 
vol_prot(m) = (m/(6.02e23))*1e-3;

# Volume of the solution
vol_sol(vc,vp) = vc - vp;

# number of ionic liquids (or any other additional compound) molecules 
num(vs,c) = round(Int,(vs*c*6.02e23));

# Volume of ionic liquids (or any other compound)  molecules
v_cos(n,m) = (n*m*1e-3)/(6.02e23);

# Number of water molecules - The number of water molecules is calculated occording to its molar mass and the volume avaiable (Box - Prot)
num_wat(vs,vil) = round(Int,((vs - vil) * 6.02e23) / (18*1e-3));

function box(pdbfile::String, solvent_file::String, concentration::Real, box_size::Real; 
             box_file="box.inp",
             topology_base="topology_base.top",
             topology_out="topology.top",
             water_file="tip4p2005.pdb")

  protein = readPDB(pdbfile)
  solvent = readPDB(solvent_file)

  protein_mass = mass(protein)
  solvent_mass = mass(solvent)

  # Box dimensions
  l = maximum(maxmin(protein).xlength)/2 + box_size 

  # Solution volume (vbox - vprotein)
  vs   = vol_box(2*l,2*l,2*l) - vol_prot(protein_mass)

  # number of solvent molecules
  ncos = num(vs,concentration) 
  vcos = v_cos(ncos,solvent_mass)

  #number of water molecules
  nwat = num_wat(vs,vcos)

  println("""

          Summary:
          ========
          Box volume = $(vol_box(2*l,2*l,2*l))
          Solution volume = $vs   
          Protein molar mass = $protein_mass
          Cossolvent molar mass = $solvent_mass
          Cossolvent volume = $vcos 
          Number of cossolvent molecules = $ncos 
          Volume of water molecules = $(vs-vcos)
          Number of water molecules = $nwat
          """)

  
  open(box_file,"w") do io
    println(io,"""
                tolerance 2.0
                output system.pdb
                add_box_sides 1.0
                filetype pdb
                seed -1

                structure $pdbfile
                  number 1
                  center
                  fixed 0. 0. 0. 0. 0. 0.
                end structure

                structure $water_file
                  number $nwat
                  inside box -$l -$l -$l $l $l $l
                end structure

                structure $solvent_file
                  number $ncos
                  inside box -$l -$l -$l $l $l $l
                end structure
                """)
 end
 println("Wrote file: $box_file")
  

 # Read base topology and write new topolgy with actual numbers
 open(topology_out,"w") do output
   open(topology_base,"r") do input
     for line in eachline(input)
       line = replace(line,"NWAT" => "$nwat") 
       line = replace(line,"NCOS" => "$ncos")
       println(output,line)
     end
   end
 end
 println("Wrote file: $topology_out\n")

end # function box

end # module

