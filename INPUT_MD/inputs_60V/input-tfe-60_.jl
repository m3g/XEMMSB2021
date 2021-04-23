  # This script read pdb files and write inp inputs for using in packmol.
  
  function measure_prot(nome)
  
  ## Variables - Measurement of the protein(X, Y and Z axis)
    pdbfile   = nome
    segment   = "all"
    restype   = "all"
    atomtype  = "all"
    firstatom = "all"
    lastatom  = "all"
  
  ## Open the file - 
    file    = open("$pdbfile","r+")
    natoms  = 0
    var     = 0
   
    for line in eachline(file)
  
      data = split(line)
      consider = false
      if data[1] == "ATOM" || data[1] == "HEATOM"
        natoms = natoms + 1
        ss = data[11]
        rt = data[4]
        at = data[3]
        consider = true
      else
        continue
      end  
  
      if firstatom != "all"
        if natoms < firstatom
          consider = false
        end
      end
  
      if lastatom != "all"    
        if natoms > lastatom  
          consider = false                                  
        end                    
      end                      
  
      if segment != "all"    
        if ss != segment  
          consider = false     
        end                    
      end                      
  
      if restype != "all"    
        if rt != restype  
          consider = false     
        end                    
      end                      
  
      if atomtype != "all"    
        if at != atomtype  
          consider = false     
        end                    
      end  
  
      if consider == true
        global x = parse(Float64,data[7])
        global y = parse(Float64,data[8])
        global z = parse(Float64,data[9])
      end
      
      if var == 1
        if x < xmin
            xmin = x
        end
        if y < ymin
            ymin = y
        end
        if z < zmin
            zmin = z
        end
        if x > xmax
            xmax = x
        end
        if y > ymax
            ymax = y
        end
        if z > zmax
            zmax = z
        end
      else
  
        global   xmin = x
        global   ymin = y
        global   zmin = z
        global   xmax = x
        global   ymax = y
        global   zmax = z
        var = 1
  
      end
  
    end
   
  ## Box size - add 28 A in each size of box
    bx = round(Int,((xmax - xmin) + 28 + 28)/2) 
    by = round(Int,((ymax - ymin) + 28 + 28)/2)
    bz = round(Int,((zmax - zmin) + 28 + 28)/2)
  
    return bx , by, bz
  
  end
  
  
  # Function to calculate number of components to put inside a box given a specific concentration
 
 # PDB UBQ = 8560

  function box(MMP::Float64, PDB::String, c::Float64)

    # Volume of the box (L)
    vol_box(a,b,c) = a*b*c*1e-27;
  
    # Volume of the protein 
    vol_prot(m) = (m/(6.02e23))*1e-3;
    
    # Volume of the solution
    vol_sol(vc,vp) = vc - vp;
  
    # number of ionic liquids (or any other additional compound) molecules 
    num(vs,c) = round(Int128,(vs*c*6.02e23));

    # Volume of ionic liquids (or any other compound)  molecules
    v_cos(n,m) = (n*m*1e-3)/(6.02e23);
    
    # Number of water molecules - The number of water molecules is calculated occording to its molar mass and the volume avaiable (Box - Prot)
    num_wat(vs,vil) = round(Int128,((vs - vil) * 6.02e23) / (18*1e-3));
  
    # Box dimensions
    #lx,ly,lz = measure_prot(PDB) 
    lx = 28  
    ly = 28
    lz = 28

    # Volume of the box
    vs   = vol_box(2*lx,2*ly,2*lz) - vol_prot(MMP); # Volume da solução
  
    # number of tfe molecules
    ncos = num(vs,c) 
    vcos = v_cos(ncos,100.4)

    #number of water molecules
    nwat = num_wat(vs,vcos)
  
    println("Important data")
    println("Box volume = ",vol_box(2*lx,2*ly,2*lz))
    println("solution volume = ", vs)  
    println("Cossolvent volume = ", vcos)
    println("Number of cossolvent molecules = ", ncos)
    println("Volume of water molecules = ",vs-vcos)
    println("Number of water molecules = ", nwat)
   

    io = open("box.inp","w")
    println(io,"tolerance 2.0")
    println(io,"output system.pdb")
    println(io,"add_box_sides 1.0")
    println(io,"filetype pdb")
    println(io,"seed -1")
    println(io,"                  ")
    println(io,"structure $PDB")
    println(io," number 1")
    println(io," center")
    println(io," fixed 0. 0. 0. 0. 0. 0.")
    println(io,"end structure")
    println(io,"                  ") 
    println(io,"structure tip4p2005.pdb")
    println(io," number $nwat")
    println(io," inside box -$(lx). -$(ly). -$(lz). $(lx). $(ly). $(lz).")
    println(io,"end structure")
    println(io,"                  ") 
    println(io,"structure tfe.pdb")
    println(io," number $ncos")
    println(io," inside box -$(lx). -$(ly). -$(lz). $(lx). $(ly). $(lz).")
    println(io,"end structure")
    close(io)

   # topology  
   nls = length(readlines("topol.top"))
   file1 = open("topol.top","r")  
   file2 = open("topol_new.top","w")
 
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

  box(1239.3588, "AAQAA.pdb", 6.)
