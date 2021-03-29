<!--This file was generated, do not modify it.-->
```julia:ex1
# CHAPTER 4 MODELS

using Turing
```

 ## 4.1

```julia:ex2
@model function m4_1(height)

    σ ~ Uniform(0, 50)
    μ ~ Normal(178, 20)

    height .~ Normal.(μ, σ)

end;
```

 ## 4.2
Same as 4.1, but with a different prior on μ.

```julia:ex3
@model function m4_2(height)

    σ ~ Uniform(0, 50)
    μ ~ Normal(178, 0.1)

    height .~ Normal.(μ, σ)

end;
```

## 4.3

```julia:ex4
@model function m4_3(height, weight, weight_mean)

    if ismissing(weight_mean)
        weight_mean = mean(weight)
    end

    α ~ Normal(178, 20)
    β ~ LogNormal(0, 10)
    σ ~ Uniform(0, 5)

    μ = α .+ β .* (weight.-weight_mean)

    for i in 1:length(height)
        height[i] ~ Normal(μ[i], σ)
    end

end;
```

Another syntax for this model follows, but does not work as well for prediction.

```julia:ex5
@model function other_m4_3(height, weight)

    α ~ Normal(178, 20)
    β ~ LogNormal(0, 10)
    σ ~ Uniform(0, 50)

    μ = α .+ β .* (weight.-mean(weight))

    height .~ Normal.(μ, σ)

end;
```

Same as 4.3, but with a different prior on β

```julia:ex6
@model function m4_3_2(height, weight, weight_mean)

    if ismissing(weight_mean)
        weight_mean = mean(weight)
    end

    α ~ Normal(178, 20)
    β ~ LogNormal(0, 1)
    σ ~ Uniform(0, 50)

    μ = α .+ β .* (weight.-weight_mean)

    for i in 1:length(height)
        height[i] ~ Normal(μ[i], σ)
    end

end;
```

## 4.5

Square model:

```julia:ex7
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
```

## 4.6

Cube model:

```julia:ex8
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
```

## 4.7

```julia:ex9
@model function m4_7(D, B)

    n_splines = size(B, 2)

    α ~ Normal(100, 10)
    w ~ MvNormal(n_splines, sqrt(10))
    σ ~ Exponential(1)

    μ = α .+ B * w

    for i in 1:length(D)
        D[i] ~ Normal(μ[i], σ)
    end

end;
```

