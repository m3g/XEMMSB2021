using Plots, LaTeXStrings, ComplexMixtures

results = ComplexMixtures.load("./results-tfe-20.json")

  C1 = results.solvent_atom[:,1]
 F11 = results.solvent_atom[:,2]
 F12 = results.solvent_atom[:,3]
 F13 = results.solvent_atom[:,4]
  C2 = results.solvent_atom[:,5]
 H21 = results.solvent_atom[:,6]
 H22 = results.solvent_atom[:,7]
   O = results.solvent_atom[:,8]
   H = results.solvent_atom[:,9]

plot_font = "Computer Modern"
default(fontfamily=plot_font)

#All: 
plot(results.d,results.mddf,xlabel=L"\mathrm{r} / \mathrm{\AA}", ylabel=L"g^{md}_{pc} \ (r)",label="Total MDDF",framestyle=:box,c=:navyblue,dpi=300,xtickfontsize=18,ytickfontsize=18,xguidefontsize=18,yguidefontsize=18,legendfontsize=14,lw=3,minorticks=Integer)

#F11, F12, F13:
plot!(results.d,F11.+F12.+F13,xlabel=L"\mathrm{r} / \mathrm{\AA}", ylabel=L"g^{md}_{pc} \ (r)",label="Fluorine atoms",framestyle=:box,c=:green1,dpi=300,xtickfontsize=18,ytickfontsize=18,xguidefontsize=18,yguidefontsize=18,legendfontsize=14,lw=3,minorticks=Integer)

#H:
plot!(results.d,H,xlabel=L"\mathrm{r} / \mathrm{\AA}", ylabel=L"g^{md}_{pc} \ (r)",label="H",framestyle=:box,c=:grey44,dpi=300,xtickfontsize=18,ytickfontsize=18,xguidefontsize=18,yguidefontsize=14,legendfontsize=18,lw=3,minorticks=Integer)

#H21, H22
plot!(results.d,H21.+H22,xlabel=L"\mathrm{r} / \mathrm{\AA}", ylabel=L"g^{md}_{pc} \ (r)",label="H21 + H22",framestyle=:box,c=:grey72,dpi=300,xtickfontsize=18,ytickfontsize=18,xguidefontsize=18,yguidefontsize=18,legendfontsize=14,lw=3,minorticks=Integer)

#O:
plot!(results.d,O,xlabel=L"\mathrm{r} / \mathrm{\AA}", ylabel=L"g^{md}_{pc} \ (r)",label="O",framestyle=:box,c=:red,dpi=300,xtickfontsize=18,ytickfontsize=18,xguidefontsize=18,yguidefontsize=14,legendfontsize=18,lw=3,minorticks=Integer)


#C1, C2:
plot!(results.d,C1.+C2,xlabel=L"\mathrm{r} / \mathrm{\AA}", ylabel=L"g^{md}_{pc} \ (r)",label="Carbon atoms",framestyle=:box,c=:black,dpi=300,xtickfontsize=18,ytickfontsize=18,xguidefontsize=18,yguidefontsize=18,legendfontsize=14,lw=3,minorticks=Integer)

# Save figure
savefig("./mddf-contributions-tfe.png")

# KB-integral
plot(results.d,results.kb/1000,xlabel=L"\mathrm{r} / \mathrm{\AA}", ylabel=L"{G_{pc}} \ (r) / \mathrm{L\ mol^{-1}}",label=false,framestyle=:box,c=:navyblue,dpi=300,xtickfontsize=18,ytickfontsize=18,xguidefontsize=18,yguidefontsize=18,legendfontsize=18,lw=3,minorticks=Integer)

# Save figure
savefig("./kb-integral-tfe.png")

