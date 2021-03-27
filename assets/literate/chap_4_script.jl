# This file was generated, do not modify it.

include("src/load_packages.jl");
include("src/models/chap_4_models.jl");

data_path = joinpath(TuringModels.project_root, "data", "Howell1.csv")
howell = CSV.read(data_path, DataFrame; delim=';')
howell = filter(row -> row.age >= 18, howell)
first(howell, 5)

m4_1_model = m4_1(howell.height)
m4_1_chains = sample(m4_1_model, NUTS(0.65), 1000)
m4_1_chains_plot = plot(m4_1_chains)
savefig(m4_1_chains_plot, joinpath(@OUTPUT, "m4_1_plot.svg")); #src

m4_1_map_estimate = optimize(m4_1_model, MAP())
vcov(m4_1_map_estimate)

m4_2_model = m4_2(howell.height)
m4_2_chains = sample(m4_2_model, NUTS(0.65), 1000)
m4_2_chains_plot =plot(m4_2_chains)
savefig(m4_2_chains_plot, joinpath(@OUTPUT, "m4_2_plot.svg")); #src

m4_2_map_estimate = optimize(m4_2_model, MAP())
vcov(m4_2_map_estimate)

m4_3_model = m4_3(howell.height, howell.weight, missing)
m4_3_2_model = m4_3_2(howell.height, howell.weight, missing);

m4_3_chains_prior = sample(m4_3_model, Prior(), 100)
m4_3_2_chains_prior = sample(m4_3_2_model, Prior(), 100);

xi = minimum(howell.weight):0.1:maximum(howell.weight)
p = plot();

for row in 1:length(m4_3_chains_prior)
    yi = m4_3_chains_prior[:α][row] .+ m4_3_chains_prior[:β][row] .* (xi .- mean(howell.weight))
    plot!(p, xi, yi, alpha=0.3, color="#000000", lab="")
end

hline!(p, [0], ls=:dash, color="#000000", lab="");
hline!(p, [272], color="#000000", lab="");
plot!(p, ylims = [-100, 400], title="log(b) ~ N(0, 1)", xlab="weight", ylab="height", lab="");

p2 = plot();

for row in 1:length(m4_3_2_chains_prior)
    yi = m4_3_2_chains_prior[:α][row] .+ m4_3_2_chains_prior[:β][row] .* (xi .- mean(howell.weight))
    plot!(p2, xi, yi, alpha=0.3, color="#000000", lab="")
end

hline!(p2, [0], ls=:dash, color="#000000", lab="");
hline!(p2, [272], color="#000000", lab="");
plot!(p2, ylims = [-100, 400], title="log(b) ~ N(0, 10)", xlab="weight", ylab="height", lab="");

figure_4_5 = plot(p, p2, layout = (1, 2), legend = false)
savefig(figure_4_5, joinpath(@OUTPUT, "figure_4_5.svg")); #src

m4_3_chains = sample(m4_3_model, NUTS(0.65), 1000)
m4_3_chains_plot = plot(m4_3_chains)
savefig(m4_3_chains_plot, joinpath(@OUTPUT, "m4_3_plot.svg")); #src

m4_3_map_estimate = optimize(m4_3_model, MAP())
vcov(m4_3_map_estimate)

p = scatter(howell.weight, howell.height, xlab="weight", ylab="height", lab="");
savefig(p, joinpath(@OUTPUT, "figure_4_6.svg")); #src

for row in 1:length(m4_3_chains)
    yi = m4_3_chains[:α][row] .+ m4_3_chains[:β][row] .* (xi .- mean(howell.weight))
    plot!(p, xi, yi, alpha=0.01, color="#000000", lab="");
end

savefig(p, joinpath(@OUTPUT, "figure_4_9_a.svg")); #src

res = DataFrame(m4_3_chains)

function m4_3_model_eq(weight, α, β, mean_weight)
    height = α + β * (weight .- mean_weight)
end

arr = [m4_3_model_eq.(w, res.α, res.β, mean(howell.weight)) for w in xi]
m = [mean(v) for v in arr]

quantiles = [quantile(v, [0.1, 0.9]) for v in arr]

lower = [q[1] - m for (q, m) in zip(quantiles, m)]
upper = [q[2] - m for (q, m) in zip(quantiles, m)]

p2 = scatter(howell.weight, howell.height, lab="")
plot!(p2, xi, m, ribbon = [lower, upper], xlab="weight", ylab="height", lab="")

savefig(p2, joinpath(@OUTPUT, "figure_4_9_b.svg")); #src

x_pred = xi
m_test = m4_3(Vector{Union{Missing, Float64}}(undef, length(x_pred)), hcat(x_pred), mean(howell.weight));
predictions = predict(m_test, m4_3_chains)

pred_array = Array(group(predictions, :height))
quantiles_pred = [quantile(col, [0.1, 0.9]) for col in eachcol(pred_array)]
m_pred = [mean(v) for v in eachcol(pred_array)]
lower_pred = [q[1] - m for (q, m) in zip(quantiles_pred, m_pred)]
upper_pred = [q[2] - m for (q, m) in zip(quantiles_pred, m_pred)]

p3 = scatter(howell.weight, howell.height, lab="")
plot!(p3, xi, m, ribbon = [lower, upper], lab="")
plot!(p3, x_pred, m_pred, ribbon = [lower_pred, upper_pred], xlab="weight", ylab="height", lab="")

savefig(p3, joinpath(@OUTPUT, "figure_4_10.svg")); #src

