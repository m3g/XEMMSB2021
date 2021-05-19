using Plots
using LaTeXStrings

default(fontfamily="Computer Modern", size=(400,300),
        linewidth=2, framestyle=:box, label=nothing, grid=false)

T₀ = 300.
Tₘ = 600.
n = 100

λ = [exp((-i/n)*log(Tₘ/T₀)) for i in 0:n]
T = T₀ ./ λ

plot(T,λ,xlabel=L"T/K",ylabel=L"\lambda")
savefig("./lambda.png")

