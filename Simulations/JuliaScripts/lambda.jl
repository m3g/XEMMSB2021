using Plots
using LaTeXStrings

default(fontfamily="Computer Modern", size=(400,300),
        linewidth=2, framestyle=:box, label=nothing, grid=false)

λ = [exp((-i/3)*log(425/300)) for i in 0:20]

plot(λ,xlabel=L"i",ylabel=L"\lambda")

savefig("./lambda.png")

