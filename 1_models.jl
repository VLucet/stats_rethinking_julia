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
# @model function m4_3(height, weight)
#     α ~ Normal(178, 20)
#     β ~ LogNormal(0, 1)
#     μ = α .+ β .* (weight.-mean(weight))
#     σ ~ LogNormal(0, 50)
#     height .~ Normal.(μ, σ)
# end

# Equivalent to:
@model function m4_3(height, weight, weight_mean)
    
    if ismissing(weight_mean)
        weight_mean = mean(weight)
    end
    
    α ~ Normal(178, 20)
    β ~ LogNormal(0, 1)
    μ = α .+ β .* (weight.-weight_mean)
    σ ~ LogNormal(0, 5) # Changes the prior here

    for i in 1:length(height)
        height[i] ~ Normal(μ[i], σ)
    end

end

m4_3_model = m4_3(df.height, df.weight, missing)
# m4_3_chains = sample(m4_3_model, NUTS(), MCMCThreads(), 1000, 4)
m4_3_chains = sample(m4_3_model, NUTS(0.65), 1000)
StatsPlots.plot(m4_3_chains)
m4_3_map_estimate = optimize(m4_3_model, MAP())
vcov(m4_3_map_estimate)

xi = minimum(df.weight):0.1:maximum(df.weight)
p = scatter(df.weight, df.height)

for row in 1:length(m4_3_chains)
    yi = m4_3_chains[:α][row] .+ m4_3_chains[:β][row] .* (xi .- mean(df.weight))
    plot!(p, xi, yi, alpha=0.01, color="#000000", lab="")
end

plot(p)

# Credibility interval
# https://stackoverflow.com/questions/62028147/plotting-credible-intervals-in-julia-from-turing-model

res = DataFrame(m4_3_chains)

function m4_3_model_eq(weight, α, β, mean_weight) 
    height = α + β * (weight .- mean_weight) 
end

arr = [m4_3_model_eq.(w, res.α, res.β, mean(df.weight)) for w in xi]
m = [mean(v) for v in arr]

quantiles = [quantile(v, [0.1, 0.9]) for v in arr]

lower = [q[1] - m for (q, m) in zip(quantiles, m)]
upper = [q[2] - m for (q, m) in zip(quantiles, m)]

p2 = scatter(df.weight, df.height, lab="")
plot!(p2, xi, m, ribbon = [lower, upper], lab="")

# Prediction interval

# @model function m4_3_test(height, weight)
#     α ~ Normal(178, 20)
#     β ~ LogNormal(0, 1)
#     μ = α .+ β .* (weight.-mean(weight))
#     σ = 0.1
#     height .~ Normal.(μ, σ)
# end
# m4_3_model_test = m4_3_test(df.height, df.weight)
# m4_3_chains_test = sample(m4_3_model_test, NUTS(0.65), 1000)

x_pred = xi
m_test = m4_3(Vector{Union{Missing, Float64}}(undef, length(x_pred)), hcat(x_pred), mean(df.weight));
predictions = predict(m_test, m4_3_chains)

pred_array = Array(group(predictions, :height))
quantiles_pred = [quantile(col, [0.1, 0.9]) for col in eachcol(pred_array)]
m_pred = [mean(v) for v in eachcol(pred_array)]
lower_pred = [q[1] - m for (q, m) in zip(quantiles_pred, m_pred)]
upper_pred = [q[2] - m for (q, m) in zip(quantiles_pred, m_pred)]

p3 = scatter(df.weight, df.height, lab="")
plot!(p3, xi, m, ribbon = [lower, upper], lab="")
plot!(p3, x_pred, m_pred, ribbon = [lower_pred, upper_pred], lab="")

png(p3, "plots/reg_1.png")