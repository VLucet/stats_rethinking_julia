# This file was generated, do not modify it. # hide
xi_s = minimum(howell_all.weight_s):0.1:maximum(howell_all.weight_s)
x_pred_s = xi_s

m4_3_model_s = m4_3(howell_all.height, howell_all.weight_s, 0)
m4_3_chains_s = sample(m4_3_model_s, NUTS(0.65), 1000)
res_4_3_s = DataFrame(m4_3_chains_s)
arr_4_3_s = [m4_3_model_eq.(w, res_4_3_s.α, res_4_3_s.β, 0) for w in xi_s]

compat_interval_4_3_s = compat_interval(0.1, 0.9, arr_4_3_s)

m4_3_test_s = m4_3(Vector{Union{Missing, Float64}}(undef, length(x_pred_s)),
              vcat(x_pred_s), mean(howell_all.weight_s));
predict_interval_4_3_s = predict_interval(0.1, 0.9, m4_3_test_s, m4_3_chains_s, "height")

p1 = scatter(howell_all.weight_s, howell_all.height,
             xlab="weight_s", ylab="height", lab="", title = "Linear")
plot!(p1, xi_s, compat_interval_4_3_s[2],
      ribbon = [compat_interval_4_3_s[1], compat_interval_4_3_s[3]], lab="")
plot!(p1, x_pred_s, predict_interval_4_3_s[2],
      ribbon = [predict_interval_4_3_s[1], predict_interval_4_3_s[3]], lab="");