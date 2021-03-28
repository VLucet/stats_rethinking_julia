# This file was generated, do not modify it. # hide
@model function other_m4_3(height, weight)

    α ~ Normal(178, 20)
    β ~ LogNormal(0, 10)
    σ ~ Uniform(0, 50)

    μ = α .+ β .* (weight.-mean(weight))

    height .~ Normal.(μ, σ)

end;