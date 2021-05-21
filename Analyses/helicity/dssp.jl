using Plots, Statistics, PDBTools

function get_helicity(dir,nresidues)
  files = filter(f -> f[end-4:end] == ".dssp", readdir(dir))
  nfiles = length(files)  
  helix = zeros(Int,nfiles,nresidues)
  for i in 0:nfiles-1
    file = open("$dir/dssp$i.pdb.dssp","r")
    residue_start = false
    for line in eachline(file)
      # skip header
      if occursin("RESIDUE",line)
        residue_start = true
        continue
      end
      if ! residue_start 
        continue
      end
      # read data: columns 6:10 contain the residue number,
      # it data for the residue is available
      try
        residue = parse(Int,line[6:10])
        # If 17th character is an 'H', an helix was attributed
        # to this residue
        if line[17] == 'H'
          helix[i+1,residue] = 1
        end
      catch
        continue
      end
    end
    close(file)
  end
  avg_helicity_per_frame = [ mean(helix[i,:]) for i in 1:nfiles ]
  avg_helicity_per_residue = [ mean(helix[:,i]) for i in 1:nresidues ]
  return nfiles, avg_helicity_per_frame, avg_helicity_per_residue
end

# working directory
work = ARGS[1]
if ! isdir(work)
  error("Run with: dssp.jl \$work")
end
println("\nParse DSSP files \n")

# Number or residues of peptide
peptide = readPDB("$work/Simulations/AAQAA_0vv/system.pdb","protein")
sequence = getseq(peptide)
nresidues = length(sequence)
println("Number of peptide residues: $nresidues")
println("Sequence: $sequence")

# pure water
dir="$work/Simulations/AAQAA_0vv/0/DSSP"
nfiles_pure, pure_per_frame, pure_per_residue = 
  get_helicity(dir,nresidues)
println("Number of frames in $dir: $nfiles_pure")

# with TFE
nfiles_tfe, tfe_per_frame, tfe_per_residue = 
  get_helicity("$work/Simulations/AAQAA_60vv/0/DSSP",nresidues)
println("Number of frames in $dir: $nfiles_tfe")


# plot
println("Plotting...")
default(fontfamily="Computer Modern",linewidth=1,framestyle=:box)
plot(layout=(2,1))

# helicity as a function of time
sp=1
plot!(1:nfiles_pure,pure_per_frame,label="Water",subplot=sp)
plot!(1:nfiles_tfe,tfe_per_frame,label="Water/TFE",subplot=sp)
plot!(xlabel="frame",
      ylabel="α-helical content (%)",
      subplot=sp)

# helicity per residue 
sp=2
plot!(1:nresidues,100*pure_per_residue,label="Water",subplot=sp)
plot!(1:nresidues,100*tfe_per_residue,label="Water/TFE",subplot=sp)
plot!(xlabel="residue",
      ylabel="α-helical content (%)",
      xticks=(1:nresidues,["$(sequence[i])$i" for i in 1:nresidues]),
      xrotation=60,
      subplot=sp)

savefig("$work/Simulations/helicity.pdf")
println("Wrote file: $work/Simulations/helicity.pdf \n")

