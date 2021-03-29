# This file was generated, do not modify it. # hide
@model function m4_7(D, B)

    n_splines = size(B, 2)

    α ~ Normal(100, 10)
    w ~ MvNormal(n_splines, sqrt(10))
    σ ~ Exponential(1)

    μ = α .+ B * w

    for i in 1:length(D)
        D[i] ~ Normal(μ[i], σ)
    end

end