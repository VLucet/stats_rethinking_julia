# This file was generated, do not modify it. # hide
contour_plot = contour(μ_vec, σ_vec, post_prob)
savefig(contour_plot, joinpath(@OUTPUT, "contour_plot.svg")); #src