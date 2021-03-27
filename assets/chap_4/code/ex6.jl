# This file was generated, do not modify it. # hide
μ_vec = range(150, 160, length = 100)
σ_vec = range(7, 9, length = 100)
post_grid = reduce(vcat, collect(Iterators.product(μ_vec, σ_vec)))