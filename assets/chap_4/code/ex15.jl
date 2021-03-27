# This file was generated, do not modify it. # hide
res = DataFrame(m4_3_chains)

function m4_3_model_eq(weight, α, β, mean_weight)
    height = α + β * (weight .- mean_weight)
end

arr = [m4_3_model_eq.(w, res.α, res.β, mean(howell.weight)) for w in xi]
m = [mean(v) for v in arr]

quantiles = [quantile(v, [0.1, 0.9]) for v in arr]

lower = [q[1] - m for (q, m) in zip(quantiles, m)]
upper = [q[2] - m for (q, m) in zip(quantiles, m)]

p2 = scatter(howell.weight, howell.height, lab="")
plot!(p2, xi, m, ribbon = [lower, upper], xlab="weight", ylab="height", lab="")

savefig(p2, joinpath(@OUTPUT, "figure_4_9_b.svg")); #src