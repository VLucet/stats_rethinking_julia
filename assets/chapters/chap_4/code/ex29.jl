# This file was generated, do not modify it. # hide
res_4_5 = DataFrame(m4_5_chains)

function m4_5_model_eq(weight, weight_squared, α, β1, β2)
    height = α + β1 * weight + β2 * weight_squared
end

arr_4_5 = [m4_5_model_eq.(w, w_2, res_4_5.α, res_4_5.β1, res_4_5.β2)
           for (w, w_2) in zip(xi_s, xi_s.^2)]
compat_interval_4_5 = compat_interval(0.1, 0.9, arr_4_5)

m4_5_test = m4_5(Vector{Union{Missing, Float64}}(undef, length(x_pred_s)),
                 vcat(x_pred_s), vcat(x_pred_s.^2));
predict_interval_4_5 = predict_interval(0.1, 0.9, m4_5_test, m4_5_chains, "height")

p2 = scatter(howell_all.weight_s, howell_all.height,
             xlab="weight_s", ylab="height", lab="", title = "Quadratic")
plot!(p2, xi_s, compat_interval_4_5[2],
      ribbon = [compat_interval_4_5[1], compat_interval_4_5[3]], lab="")
plot!(p2, x_pred_s, predict_interval_4_5[2],
      ribbon = [predict_interval_4_5[1], predict_interval_4_5[3]], lab="");