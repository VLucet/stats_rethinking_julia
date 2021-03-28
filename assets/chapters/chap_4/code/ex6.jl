# This file was generated, do not modify it. # hide
μ_vec = range(150, 160, length = 100)
σ_vec = range(7, 9, length = 100)

post_grid = reduce(vcat, collect(Iterators.product(μ_vec, σ_vec)))
post_grid_dist = [Normal(t[1], t[2]) for t in post_grid]
log_likelihood = sum.([log.(pdf.(d, howell.height)) for d in post_grid_dist])

all_μ = [p[1] for p in post_grid]
all_σ = [p[2] for p in post_grid]

post_prod = log_likelihood .+ log.(pdf(Normal(178, 20), all_μ))
                           .+ log.(pdf(Uniform(0, 50), all_σ))
post_prob = exp.(post_prod .- maximum(post_prod));