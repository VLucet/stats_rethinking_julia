# This file was generated, do not modify it. # hide
p1 = plot(Normal(178,20), xlab = "μ", ylab = "Density", lab = "",
          title = "μ ~ N(178, 20)", linecolor=:blue)

p2 = plot(Uniform(0,50), xlab = "σ", ylab = "Density", lab = "",
          title = "σ ~ N(0, 50)", linecolor=:blue,
          xlim=[-10, 60], ylim=[0, 0.02])

sample_μ = rand(Normal(178, 20), 10_000)
sample_μ_2 = rand(Normal(178, 100), 10_000)
sample_σ = rand(Uniform(0,50), 10_000)

prior_h = rand.(Normal.(sample_μ, sample_σ), 1)
p3 = density(reduce(vcat, prior_h),
             xlab = "height", ylab = "Density", lab = "",
             title = "h ~ N(μ, σ)")

prior_h_2 = rand.(Normal.(sample_μ_2, sample_σ), 1)
p4 = density(reduce(vcat, prior_h_2),
             xlab = "height", ylab = "Density", lab = "",
             title = "h ~ N(μ, σ)\nμ ~ N(178, 100)")

figure_4_3 = plot(p1, p2, p3, p4, layout = (2, 2));

savefig(figure_4_3, joinpath(@OUTPUT, "figure_4_3.svg")); #src