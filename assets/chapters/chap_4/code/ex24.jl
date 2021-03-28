# This file was generated, do not modify it. # hide
x_pred = xi

m4_3_test = m4_3(Vector{Union{Missing, Float64}}(undef, length(x_pred)),
                 vcat(x_pred), mean(howell.weight));

function predict_interval(test, chains, var)

    predictions = predict(test, chains)
    pred_array = Array(group(predictions, var))
    quantiles_pred = [quantile(col, [0.1, 0.9]) for col in eachcol(pred_array)]

    m_pred = [mean(v) for v in eachcol(pred_array)]
    lower_pred = [q[1] - m for (q, m) in zip(quantiles_pred, m_pred)]
    upper_pred = [q[2] - m for (q, m) in zip(quantiles_pred, m_pred)]

    return(lower_pred, m_pred, upper_pred)
end

predict_interval_4_3 = predict_interval(m4_3_test, m4_3_chains, "height")

p3 = scatter(howell.weight, howell.height, lab="")
plot!(p3, xi, compat_interval_4_3[2],
      ribbon = [compat_interval_4_3[1], compat_interval_4_3[3]], lab="")
plot!(p3, x_pred, predict_interval_4_3[2],
      ribbon = [predict_interval_4_3[1], predict_interval_4_3[3]],
      xlab="weight", ylab="height", lab="")

savefig(p3, joinpath(@OUTPUT, "figure_4_10.svg")); #src