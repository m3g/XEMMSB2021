  using Suppressor   

  function input_gen()
    nrep = parse(Int64,readline()) 
     
    files_dir = "../"
    main_dir = pwd()

    # temps = [300.00, 311.84, 324.14, 336.93, 350.23, 364.05, 378.41, 393.35, 408.87, 425.00]

    temps  = [300.00, 300.00, 300.00, 300.00, 300.00, 300.00, 300.00, 300.00, 300.00, 300.00]
    pars   = [1.00, 0.96, 0.93, 0.89, 0.86, 0.82, 0.79, 0.76, 0.73, 0.71] 
    
    h = 0
    for i in 0:(nrep-1)
      run(`cp plumed.dat ./$i`)   
      h = h +1
      for f in ["nvt", "npt", "prod"]
        file = open("../mdp_files/$f.mdp","r")
        cd("$main_dir/$i")
        filer = open("$f$i.mdp","w")
                              
        for line in eachline(file)
          if occursin("REFT",line)
            println(filer,replace(line,"REFT" => "$(temps[h])")) 
          else
            println(filer, line)
          end
        end

        close(filer)
        close(file)

        cd("$main_dir")
      end
           
      # plumed partial-tempering calculation
      var = pars[h]
      output = @capture_out run(pipeline(`cat processed.top`,`plumed partial_tempering $var`))   # se der erro, usar: plumed-partial_tempering   
      open("./$i/topol$i.top","w") do io
        write(io, output)  
      end
      run(`gmx_mpi grompp -f $i/nvt$i.mdp -c minimization.gro  -p $i/topol$i.top -o $i/canonical.tpr -maxwarn 3`)
  
    end

  end
  input_gen()
