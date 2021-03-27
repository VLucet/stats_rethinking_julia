# This file was generated, do not modify it. # hide
x_pred = xi
m_test = m4_3(Vector{Union{Missing, Float64}}(undef, length(x_pred)), hcat(x_pred), mean(howell.weight));
predictions = predict(m_test, m4_3_chains)

pred_array = Array(group(predictions, :height))
quantiles_pred = [quantile(col, [0.1, 0.9]) for col in eachcol(pred_array)]
m_pred = [mean(v) for v in eachcol(pred_array)]
lower_pred = [q[1] - m for (q, m) in zip(quantiles_pred, m_pred)]
upper_pred = [q[2] - m for (q, m) in zip(quantiles_pred, m_pred)]

p3 = scatter(howell.weight, howell.height, lab="")
plot!(p3, xi, m, ribbon = [lower, upper], lab="")
plot!(p3, x_pred, m_pred, ribbon = [lower_pred, upper_pred], xlab="weight", ylab="height", lab="")

savefig(p3, joinpath(@OUTPUT, "figure_4_10.svg")); #src