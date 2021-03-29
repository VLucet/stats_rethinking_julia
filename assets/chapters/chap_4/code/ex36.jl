# This file was generated, do not modify it. # hide
function m4_7_model_eq(α, mat_basis, w)
    D = α .+ mat_basis * w
end

arr_4_7 = [m4_7_model_eq(m4_7_res[i,18], basis_matrix, m4_7_res[i,1:17])
           for i in 1:size(m4_7_res, 1)]
mat_4_7 = reduce(vcat, arr_4_7)

mean_vector = [mean(mat_4_7[i,:]) for i in 1:size(mat_4_7, 1)]
quantiles = [quantile(mat_4_7[i,:], [0.1, 0.9]) for i in 1:size(mat_4_7, 1)]
lower = [q[1] - m for (q, m) in zip(quantiles, mean_vector)]
upper = [q[2] - m for (q, m) in zip(quantiles, mean_vector)]

p3 = scatter(cherry_dat.year, cherry_dat.doy, alpha = 0.2, lab = "")
spline = optimal.values[1] .+ basis_matrix * optimal.values[2:18]
plot!(p3, cherry_dat.year, spline, linewidth=3, lab = "",
      xlab = "year", ylab = "Day in year")
plot!(p3, cherry_dat.year, mean_vector,
      ribbon = [lower, upper], lab="", linewidth=0)

figure_4_12 = plot(p1, p2, p3, layout = (3,1));
savefig(figure_4_12, joinpath(@OUTPUT, "figure_4_12.svg")); #src