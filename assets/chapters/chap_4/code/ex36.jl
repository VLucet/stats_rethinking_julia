# This file was generated, do not modify it. # hide
p3 = scatter(cherry_dat.year, cherry_dat.doy, alpha = 0.2, lab = "")
spline = optimal.values[1] .+ basis_matrix * optimal.values[2:18]
plot!(p3, cherry_dat.year, spline, linewidth=3, lab = "",
      xlab = "year", ylab = "Day in year") ;