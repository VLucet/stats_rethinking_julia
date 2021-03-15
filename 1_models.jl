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
