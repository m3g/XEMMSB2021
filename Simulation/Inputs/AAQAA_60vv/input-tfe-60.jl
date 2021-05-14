#
# This script read pdb files and write inp inputs for using in packmol.
#
module CreateInput

  using PDBTools

  export box

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

  function box(pdbfile::String, solvent_file::String, concentration::Real, box_size::Vector{<:Real}; selection="all")

    protein = readPDB(pdbfile,selection)
    solvent = readPDB(solvent_file)

    protein_mass = mass(atoms)
    solvent_mass = mass(solvent)

    # Box dimensions
    lx, ly, lz .= box_size
  
    # Solution volume (vbox - vprotein)
    vs   = vol_box(2*lx,2*ly,2*lz) - vol_prot(protein_mass)
  
    # number of tfe molecules
    ncos = num(vs,c) 
    vcos = v_cos(ncos,solvent_mass)
  
    #number of water molecules
    nwat = num_wat(vs,vcos)
  
    println("""
            Important data:
            Box volume = $(vol_box(2*lx,2*ly,2*lz))
            solution volume = $vs   
            Cossolvent volume = $vcos 
            Number of cossolvent molecules = $ncos 
            Volume of water molecules = $(vs-vcos)
            Number of water molecules = $nwat
            """)
  
    io = open("box.inp","w")
    println(io,"""
                tolerance 2.0
                output system.pdb
                add_box_sides 1.0
                filetype pdb
                seed -1

                structure $PDB
                  number 1
                  center
                  fixed 0. 0. 0. 0. 0. 0.
                end structure

                structure tip4p2005.pdb
                  number $nwat
                  inside box -$lx -$ly -$lz $lx $ly $lz
                end structure

                structure $solvent_file
                  number $ncos
                  inside box -$(lx). -$(ly). -$(lz). $(lx). $(ly). $(lz)
                end structure
                """)
    close(io)
  
   # topology  
   file1 = open("topol_back.top","r")  
   file2 = open("topol.top","w")
   for line in eachline(file1)   
     if occursin("NWAT",line) 
       println(file2,replace(line,"NWAT" => "$nwat",count = 1))
     elseif occursin("NCOS",line) 
       println(file2,replace(line,"NCOS" => "$ncos",count = 1))
     else
       println(file2,line)
     end
   end
   close(file1)
   close(file2)
  
  end

end

using .CreateInput

protein_file = ARGS[1]
solvent_file = ARGS[2]

box(ARGS[1],ARGS[2],)

box(1239.3588, "AAQAA.pdb", 6.)




