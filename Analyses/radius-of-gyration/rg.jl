using Plots, LaTeXStrings, StatsPlots

include("read_files.jl")

data1,x1,y1=readfile("./rg0vv.xvg")
data2,x2,y2=readfile("./rg60vv.xvg")

default(fontfamily="Computer Modern",linewidth=1,framestyle=:box)

density(y1,framestyle=:box,c=:orangered1,dpi=300,xtickfontsize=18,ytickfontsize=18,xguidefontsize=18,yguidefontsize=18,legendfontsize=14,grid=false,xlabel=L"\mathrm{R_g} \ \mathrm{(nm)}",ylabel=L"\mathrm{Probability \ density}",lw=3,minorticks=Integer,label=L"\mathrm{(AAQAA)_3 \ in \ Water}")

density!(y2,framestyle=:box,c=:blue,dpi=300,xtickfontsize=18,ytickfontsize=18,xguidefontsize=18,yguidefontsize=18,legendfontsize=14,grid=false,xlabel=L"\mathrm{R_g} \ \mathrm{(nm)}",ylabel=L"\mathrm{Probability \ density}",lw=3,minorticks=Integer,label=L"\mathrm{(AAQAA)_3 \ in \ TFE}")

savefig("./rg.png")
