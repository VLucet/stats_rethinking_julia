# This file was generated, do not modify it. # hide
@model function m4_2(height)

    σ ~ Uniform(0, 50)
    μ ~ Normal(178, 0.1)

    height .~ Normal.(μ, σ)

end;