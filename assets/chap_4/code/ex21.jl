# This file was generated, do not modify it. # hide
μ_at_50 = samples_N_all.α .+ samples_N_all.β .* (50 - mean(howell.weight))

figure_4_8 = density(μ_at_50, xlab="μ | weight = 50", ylab="Density", lab="");

savefig(figure_4_8, joinpath(@OUTPUT, "figure_4_8.svg")); #src