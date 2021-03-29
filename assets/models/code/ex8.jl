# This file was generated, do not modify it. # hide
@model function m4_6(height, weight, weight_squared, weight_cubed)

    α ~ Normal(178, 20)
    β1 ~ LogNormal(0, 1)
    β2 ~ Normal(0,10)
    β3 ~ Normal(0,10)
    σ ~ Uniform(0, 50)

    μ = α .+ β1 .* weight .+ β2 .* weight_squared .+ β3 .* weight_cubed

    for i in 1:length(height)
        height[i] ~ Normal(μ[i], σ)
    end

end;