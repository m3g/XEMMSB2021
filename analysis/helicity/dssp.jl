using Plots, LaTeXStrings, DelimitedFiles, Statistics

    file = open("./resid", "w")
    
    println(file,1)
    println(file,2)
    println(file,3)
    println(file,4)
    println(file,5)
    println(file,6)
    println(file,7)
    println(file,8)
    println(file,9)
    println(file,10)
    println(file,11)
    println(file,12)
    println(file,13)
    println(file,14)

    close(file)

matrix0vv = readdlm("./matrix.xvg")
matrix20vv = readdlm("../20vv/matrix.xvg")

    file0vv = open("./helix0vv", "w")

    println(file0vv,mean(matrix0vv[1,:]))
    println(file0vv,mean(matrix0vv[2,:]))
    println(file0vv,mean(matrix0vv[3,:]))
    println(file0vv,mean(matrix0vv[4,:]))
    println(file0vv,mean(matrix0vv[5,:]))
    println(file0vv,mean(matrix0vv[6,:]))
    println(file0vv,mean(matrix0vv[7,:]))
    println(file0vv,mean(matrix0vv[8,:]))
    println(file0vv,mean(matrix0vv[9,:]))
    println(file0vv,mean(matrix0vv[10,:]))
    println(file0vv,mean(matrix0vv[11,:]))
    println(file0vv,mean(matrix0vv[12,:]))
    println(file0vv,mean(matrix0vv[13,:]))
    println(file0vv,mean(matrix0vv[14,:]))

    close(file0vv)

    file20vv = open("../20vv/helix20vv", "w")

    println(file20vv,mean(matrix20vv[1,:]))
    println(file20vv,mean(matrix20vv[2,:]))
    println(file20vv,mean(matrix20vv[3,:]))
    println(file20vv,mean(matrix20vv[4,:]))
    println(file20vv,mean(matrix20vv[5,:]))
    println(file20vv,mean(matrix20vv[6,:]))
    println(file20vv,mean(matrix20vv[7,:]))
    println(file20vv,mean(matrix20vv[8,:]))
    println(file20vv,mean(matrix20vv[9,:]))
    println(file20vv,mean(matrix20vv[10,:]))
    println(file20vv,mean(matrix20vv[11,:]))
    println(file20vv,mean(matrix20vv[12,:]))
    println(file20vv,mean(matrix20vv[13,:]))
    println(file20vv,mean(matrix20vv[14,:]))

    close(file20vv)

    resid = readdlm("./resid")
 helix0vv = readdlm("./helix0vv")
helix20vv = readdlm("../20vv/helix20vv")

plot_font = "Computer Modern"
default(fontfamily=plot_font)

plot(resid,helix0vv,c=:orangered1,label=L"\mathrm{(AAQAA)_3 \ in \ Water}",ylabel=L"\mathrm{\alpha-helix \ fraction}",xlabel="Residue Number",w=3,framestyle=:box,dpi=300,xtickfontsize=18,ytickfontsize=18,xguidefontsize=18,yguidefontsize=18,legendfontsize=10,minorticks=Integer,ylim=[0.,1.],legend=:topright)

plot!(resid,helix20vv,c=:blue,label=L"\mathrm{(AAQAA)_3 \ in \ TFE}",ylabel=L"\mathrm{\alpha-helix \ fraction}",xlabel="Residue Number",w=3,framestyle=:box,dpi=300,xtickfontsize=18,ytickfontsize=18,xguidefontsize=18,yguidefontsize=18,legendfontsize=10,minorticks=Integer,ylim=[0.,1.], legend=:topright)

savefig("./helicity.png")
