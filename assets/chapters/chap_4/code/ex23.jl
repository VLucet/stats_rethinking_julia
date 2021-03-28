# This file was generated, do not modify it. # hide
res_4_3 = DataFrame(m4_3_chains)

function m4_3_model_eq(weight, α, β, mean_weight)
    height = α + β * (weight .- mean_weight)
end

arr_4_3 = [m4_3_model_eq.(w, res_4_3.α, res_4_3.β, mean(howell.weight)) for w in xi]

function compat_interval(lower_bound, upper_bound, array)
    mean_vector = [mean(v) for v in array]
    quantiles = [quantile(v, [lower_bound, upper_bound]) for v in array]
    lower = [q[1] - m for (q, m) in zip(quantiles, mean_vector)]
    upper = [q[2] - m for (q, m) in zip(quantiles, mean_vector)]
    return lower, mean_vector, upper
end

compat_interval_4_3 = compat_interval(0.1, 0.9, arr_4_3)

p2 = scatter(howell.weight, howell.height, lab="")
plot!(p2, xi, compat_interval_4_3[2],
      ribbon = [compat_interval_4_3[1], compat_interval_4_3[3]],
      xlab="weight", ylab="height", lab="")

savefig(p2, joinpath(@OUTPUT, "figure_4_9_b.svg")); #src