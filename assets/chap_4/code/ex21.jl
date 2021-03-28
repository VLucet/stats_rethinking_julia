# This file was generated, do not modify it. # hide
μ_at_50 = samples_N_all.α .+ samples_N_all.β .* (50 - mean(howell.weight))

density(μ_at_50)