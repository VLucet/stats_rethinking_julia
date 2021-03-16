## STATS RETHINKING PRACTICE

# Needed libraries
import CSV
using DataFrames
using Turing
using TuringModels
using StatsPlots
using StatsBase
using Optim

# Data
data_path = joinpath(TuringModels.project_root, "data", "Howell1.csv")
df = CSV.read(data_path, DataFrame; delim=';')
df = filter(row -> row.age >= 18, df)

# m4_1
@model function m4_1(height)
    σ ~ Uniform(0, 50)
    μ ~ Normal(178, 20)

    height .~ Normal.(μ, σ)
end

m4_1_model = m4_1(df.height)
m4_1_chains = sample(m4_1_model, NUTS(0.65), 1000)
StatsPlots.plot(m4_1_chains)
m4_1_map_estimate = optimize(m4_1_model, MAP())
vcov(m4_1_map_estimate)

# m4_2, different prior on μ
@model function m4_2(height)  
    σ ~ Uniform(0, 50)
    μ ~ Normal(178, 0.1)

    height .~ Normal.(μ, σ)
end

m4_2_model = m4_2(df.height)
m4_2_chains = sample(m4_2_model, NUTS(0.65), 1000)
StatsPlots.plot(m4_2_chains)
m4_2_map_estimate = optimize(m4_2_model, MAP())
vcov(m4_2_map_estimate)

# m4_3, regression
@model function m4_3(height, weight)
    α ~ Normal(178, 20)
    β ~ LogNormal(0, 1)
    μ = α .+ β .* (weight.-mean(weight))
    σ ~ LogNormal(0, 50)
    height .~ Normal.(μ, σ)
end

# @model function m4_3(height, weight)
#     α ~ Normal(178, 20)
#     β ~ LogNormal(0, 1)
#     μ = α .+ β .* (weight.-mean(weight))
#     σ ~ LogNormal(0, 50)
#     for i in 1:length(height)
#         height[i] ~ Normal(μ[i], σ)
#     end
# end

m4_3_model = m4_3(df.height, df.weight)
m4_3_chains = sample(m4_3_model, NUTS(0.65), 1000)
StatsPlots.plot(m4_3_chains)
m4_3_map_estimate = optimize(m4_3_model, MAP())
vcov(m4_3_map_estimate)

xi = 30.0:0.1:65.0
yi = mean(m4_3_chains[:α]) .+ mean(m4_3_chains[:β])*(xi .- mean(df.weight))
scatter(df.weight, df.height, lab="Observations")
plot!(xi, yi, lab="Regression line")