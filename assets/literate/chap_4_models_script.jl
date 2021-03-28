# This file was generated, do not modify it.

# CHAPTER 4 MODELS

using Turing

@model function m4_1(height)

    σ ~ Uniform(0, 50)
    μ ~ Normal(178, 20)

    height .~ Normal.(μ, σ)

end;

@model function m4_2(height)

    σ ~ Uniform(0, 50)
    μ ~ Normal(178, 0.1)

    height .~ Normal.(μ, σ)

end;

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

@model function other_m4_3(height, weight)

    α ~ Normal(178, 20)
    β ~ LogNormal(0, 1)
    μ = α .+ β .* (weight.-mean(weight))
    σ ~ LogNormal(0, 50)

    height .~ Normal.(μ, σ)

end;

@model function m4_3_2(height, weight, weight_mean)

    if ismissing(weight_mean)
        weight_mean = mean(weight)
    end

    α ~ Normal(178, 20)
    β ~ LogNormal(0, 10)
    μ = α .+ β .* (weight.-weight_mean)
    σ ~ LogNormal(0, 5)

    for i in 1:length(height)
        height[i] ~ Normal(μ[i], σ)
    end

end

