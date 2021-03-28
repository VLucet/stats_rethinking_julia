# This file was generated, do not modify it. # hide
@model function other_m4_3(height, weight)

    α ~ Normal(178, 20)
    β ~ LogNormal(0, 1)
    μ = α .+ β .* (weight.-mean(weight))
    σ ~ LogNormal(0, 50)

    height .~ Normal.(μ, σ)

end;