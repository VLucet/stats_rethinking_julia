# This file was generated, do not modify it. # hide
@model function m4_5(height, weight, weight_squared)

    α ~ Normal(178, 20)
    β1 ~ LogNormal(0, 1)
    β2 ~ Normal(0,1)
    σ ~ Uniform(0, 50)

    μ = α .+ β1 .* weight .+ β2 .* weight_squared

    for i in 1:length(height)
        height[i] ~ Normal(μ[i], σ)
    end

end;