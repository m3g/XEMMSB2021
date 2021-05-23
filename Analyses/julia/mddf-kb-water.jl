using Plots, LaTeXStrings, ComplexMixtures

results = ComplexMixtures.load("./results-water-20.json")

  OW = results.solvent_atom[:,1]
 HW1 = results.solvent_atom[:,2]
 HW2 = results.solvent_atom[:,3]

plot_font = "Computer Modern"
default(fontfamily=plot_font)

# Total MDDF
plot(results.d,results.mddf,xlabel=L"\mathrm{r} / \mathrm{\AA}", ylabel=L"g^{md}_{pw} \ (r)",label="Total MDDF",framestyle=:box,c=:darkgreen,dpi=300,xtickfontsize=18,ytickfontsize=18,xguidefontsize=18,yguidefontsize=18,legendfontsize=14,lw=3,minorticks=Integer,ylim=[0.,2.])

# Oxygen contribution
plot!(results.d,OW,xlabel=L"\mathrm{r} / \mathrm{\AA}", ylabel=L"g^{md}_{pw} \ (r)",label="Oxygen",framestyle=:box,c=:red,dpi=300,xtickfontsize=18,ytickfontsize=18,xguidefontsize=18,yguidefontsize=18,legendfontsize=14,lw=3,minorticks=Integer)

# Hydrogen contribution
plot!(results.d,HW1.+HW2,xlabel=L"\mathrm{r} / \mathrm{\AA}", ylabel=L"g^{md}_{pw} \ (r)",label="Hydrogen atoms",framestyle=:box,c=:grey72,dpi=300,xtickfontsize=18,ytickfontsize=18,xguidefontsize=18,yguidefontsize=18,legendfontsize=14,lw=3,minorticks=Integer)

# Save figure
savefig("./mddf-contributions-water.png")

# KB-integral
plot(results.d,results.kb/1000,xlabel=L"\mathrm{r} / \mathrm{\AA}", ylabel=L"{G_{pw}} \ (r) / \mathrm{L\ mol^{-1}}",label=false,framestyle=:box,c=:darkgreen,dpi=300,xtickfontsize=18,ytickfontsize=18,xguidefontsize=18,yguidefontsize=18,legendfontsize=18,lw=3,minorticks=Integer)

# Save figure
savefig("./kb-integral-water.png")
