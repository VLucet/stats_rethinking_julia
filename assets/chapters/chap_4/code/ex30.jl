# This file was generated, do not modify it. # hide
res_4_5_2 = DataFrame(m4_5_2_chains)

function m4_5_2_model_eq(weight, weight_squared, weight_cubed, α, β1, β2, β3)
    height = α + β1 * weight + β2 * weight_squared + β3 * weight_cubed
end

arr_4_5_2 = [m4_5_2_model_eq.(w, w_2, w_3, res_4_5_2.α,
                              res_4_5_2.β1, res_4_5_2.β2, res_4_5_2.β3)
             for (w, w_2, w_3) in zip(xi_s, xi_s.^2, xi_s.^3)]
compat_interval_4_5_2 = compat_interval(0.1, 0.9, arr_4_5_2)

m4_5_2_test = m4_5_2(Vector{Union{Missing, Float64}}(undef, length(x_pred_s)),
                     vcat(x_pred_s), vcat(x_pred_s.^2), vcat(x_pred_s.^3));
predict_interval_4_5_2 = predict_interval(0.1, 0.9, m4_5_2_test, m4_5_2_chains, "height")

p3 = scatter(howell_all.weight_s, howell_all.height,
             xlab="weight_s", ylab="height", lab="", title = "Cubic")
plot!(p3, xi_s, compat_interval_4_5_2[2],
      ribbon = [compat_interval_4_5_2[1], compat_interval_4_5_2[3]], lab="")
plot!(p3, x_pred_s, predict_interval_4_5_2[2],
      ribbon = [predict_interval_4_5_2[1], predict_interval_4_5_2[3]], lab="");