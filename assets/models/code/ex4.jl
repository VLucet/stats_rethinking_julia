# This file was generated, do not modify it. # hide
@model function m4_3(height, weight, weight_mean)

    if ismissing(weight_mean)
        weight_mean = mean(weight)
    end

    α ~ Normal(178, 20)
    β ~ LogNormal(0, 1)
    μ = α .+ β .* (weight.-weight_mean)
    σ ~ LogNormal(0, 5)

    for i in 1:length(height)
        height[i] ~ Normal(μ[i], σ)
    end

end;