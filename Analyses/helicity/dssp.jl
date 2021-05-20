using Plots, Statistics

function get_helicity(dir,nresidues)
  files = filter(f -> f[end-4:end] == ".dssp", readdir(dir))
  nfiles = length(files)  
  helix = zeros(Int,nfiles,nresidues)
  for i in 0:nfiles-1
    file = open("$dir/dssp$i.pdb.dssp","r")
    residue = -1
    for line in eachline(file)
      # skip header
      if occursin("RESIDUE",line)
        residue = 0
        continue
      end
      if residue == -1
        continue
      end
      # read data
      residue += 1
      if line[17:17] == "H"
        helix[i+1,residue] = 1
      end
    end
    close(file)
  end
  avg_helicity_per_frame = [ mean(helix[i,:]) for i in 1:nfiles ]
  avg_helicity_per_residue = [ mean(helix[:,i]) for i in 1:nresidues ]
  return nfiles, avg_helicity_per_frame, avg_helicity_per_residue
end

nresidues = 18

# pure water
nfiles_pure, pure_per_frame, pure_per_residue = get_helicity("./AAQAA_0vv/0/DSSP",nresidues)

# with TFE
nfiles_tfe, tfe_per_frame, tfe_per_residue = get_helicity("./AAQAA_0vv/0/DSSP",nresidues)


# plot
default(fontfamily="Computer Modern",linewidth=2,framestyle=:box)
plot(layout=(2,1))

# helicity as a function of time
sp=1
plot!(1:nfiles_pure,pure_per_frame,label="pure water",xticks=1:nfiles_pure,subplot=sp)
plot!(1:nfiles_tfe,tfe_per_frame,label="tfe",xticks=1:nfiles_tfe,subplot=sp)
plot!(xlabel="frame",ylabel="α-helical content",subplot=sp)

# helicity per residue 
sp=2
plot!(1:nresidues,pure_per_residue,label="pure water",xticks=1:nresidues,subplot=sp)
plot!(1:nresidues,tfe_per_residue,label="tfe",xticks=1:nresidues,subplot=sp)
plot!(xlabel="residue",ylabel="α-helical content",subplot=sp)

savefig("./helicity.png")
