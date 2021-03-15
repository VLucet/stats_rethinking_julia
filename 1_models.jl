# m4.1

import CSV

using DataFrames
using Turing
using TuringModels

data_path = joinpath(TuringModels.project_root,"StatisticalRethinking.jl", "data", "Howell1.csv")
df = CSV.read(data_path, DataFrame; delim=';')
df = filter(row -> row.age >= 18, df)

@model function line(height)
    σ ~ Uniform(0, 50)
    μ ~ Normal(178, 20)

    height .~ Normal.(μ, σ)
end

model = line(df.height)