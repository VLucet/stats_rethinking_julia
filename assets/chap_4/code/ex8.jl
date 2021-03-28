# This file was generated, do not modify it. # hide
sample_rows = sample(collect(1:size(post_grid)[1]), Weights(post_prob),
                     10_000, replace = true)
sample_μ = all_μ[sample_rows]
sample_σ = all_σ[sample_rows]

figure_4_4 = scatter(sample_μ, sample_σ, lab = "", aspect_ratio = 1.5,
                     xlab = "μ", ylab = "σ", markeralpha=0.1, markersize=3);

savefig(figure_4_4, joinpath(@OUTPUT, "figure_4_4.svg")); #src