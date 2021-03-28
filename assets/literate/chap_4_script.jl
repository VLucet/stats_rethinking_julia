# This file was generated, do not modify it.

include("src/load_packages.jl");
include("src/models/chap_4_models.jl");
Random.seed!(77);

U = Uniform(-1,1)
samples = [rand(U, 16) for i in 1:1000]

sum_samples = sum.(samples)
sum_samples_4 = sum.([samples[i][1:4] for i in 1:1000])
sum_samples_8 = sum.([samples[i][1:8] for i in 1:1000])

p_dens = density(sum_samples_4, lab = "4 steps",
                 linecolor = :blue, linealpha = 0.3)
density!(p_dens, sum_samples_8, lab = "8 steps",
         linecolor = :red, linealpha = 0.3)
density!(p_dens, sum_samples, lab = "16 steps",
         linecolor = :green, linealpha = 0.3)
density!(rand(Normal(0, std(sum_samples)), 100_000),
         lab = "N ~ (0, 2.18)", linestyle = :dash);

p_paths = plot()
for path in 1:1000
    plot!(p_paths, 1:17, insert!(cumsum(samples[path]), 1, 0), lab = "",
          linecolor= :darkblue, linealpha = 0.1)
end
vline!(p_paths, [5], linestyle = :dash, linecolor = :black, lab = "")
vline!(p_paths, [9], linestyle = :dash, linecolor = :black, lab = "")
vline!(p_paths, [17], linestyle = :dash, linecolor = :black, lab = "")

figure_4_2 = plot(p_paths, p_dens, layout = (2, 1));

savefig(figure_4_2, joinpath(@OUTPUT, "figure_4_2.svg")); #src

data_path = joinpath(TuringModels.project_root, "data", "Howell1.csv")
howell = CSV.read(data_path, DataFrame; delim=';')
howell = filter(row -> row.age >= 18, howell)
first(howell, 5)

p1 = plot(Normal(178,20), xlab = "μ", ylab = "Density", lab = "",
          title = "μ ~ N(178, 20)", linecolor=:blue)

p2 = plot(Uniform(0,50), xlab = "σ", ylab = "Density", lab = "",
          title = "σ ~ N(0, 50)", linecolor=:blue,
          xlim=[-10, 60], ylim=[0, 0.02])

sample_μ = rand(Normal(178, 20), 10_000)
sample_μ_2 = rand(Normal(178, 100), 10_000)
sample_σ = rand(Uniform(0,50), 10_000)

prior_h = rand.(Normal.(sample_μ, sample_σ), 1)
p3 = density(reduce(vcat, prior_h),
             xlab = "height", ylab = "Density", lab = "",
             title = "h ~ N(μ, σ)")

prior_h_2 = rand.(Normal.(sample_μ_2, sample_σ), 1)
p4 = density(reduce(vcat, prior_h_2),
             xlab = "height", ylab = "Density", lab = "",
             title = "h ~ N(μ, σ)\nμ ~ N(178, 100)")

figure_4_3 = plot(p1, p2, p3, p4, layout = (2, 2));

savefig(figure_4_3, joinpath(@OUTPUT, "figure_4_3.svg")); #src

μ_vec = range(150, 160, length = 100)
σ_vec = range(7, 9, length = 100)

post_grid = reduce(vcat, collect(Iterators.product(μ_vec, σ_vec)))
post_grid_dist = [Normal(t[1], t[2]) for t in post_grid]
log_likelihood = sum.([log.(pdf.(d, howell.height)) for d in post_grid_dist])

all_μ = [p[1] for p in post_grid]
all_σ = [p[2] for p in post_grid]

post_prod = log_likelihood .+ log.(pdf(Normal(178, 20), all_μ))
                           .+ log.(pdf(Uniform(0, 50), all_σ))
post_prob = exp.(post_prod .- maximum(post_prod));

contour_plot = contour(μ_vec, σ_vec, post_prob)
savefig(contour_plot, joinpath(@OUTPUT, "contour_plot.svg")); #src

sample_rows = sample(collect(1:size(post_grid)[1]), Weights(post_prob),
                     10_000, replace = true)
sample_μ = all_μ[sample_rows]
sample_σ = all_σ[sample_rows]

figure_4_4 = scatter(sample_μ, sample_σ, lab = "", aspect_ratio = 1.5,
                     xlab = "μ", ylab = "σ", markeralpha=0.1, markersize=3);

savefig(figure_4_4, joinpath(@OUTPUT, "figure_4_4.svg")); #src

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

howell_10 = howell[1:10,:]
howell_50 = howell[1:50,:]
howell_150 = howell[1:150,:]

m4_3_model_N10 = m4_3(howell_10.height, howell_10.weight, missing)
m4_3_model_N50 = m4_3(howell_50.height, howell_50.weight, missing)
m4_3_model_N150 = m4_3(howell_150.height, howell_150.weight, missing)

m4_3_N10_chains = sample(m4_3_model_N10, NUTS(0.65), 1000)
m4_3_N50_chains = sample(m4_3_model_N50, NUTS(0.65), 1000)
m4_3_N150_chains = sample(m4_3_model_N150, NUTS(0.65), 1000)

the_20_rows = sample(1:1000, 20)

samples_N_all = DataFrame(m4_3_chains)[the_20_rows,[:α,:β]]
samples_N10 = DataFrame(m4_3_N10_chains)[the_20_rows,[:α,:β]]
samples_N50 = DataFrame(m4_3_N50_chains)[the_20_rows,[:α,:β]]
samples_N150 = DataFrame(m4_3_N150_chains)[the_20_rows,[:α,:β]]

function make_plot(dat, samples, N)
    p_new = scatter(dat.weight, dat.height, xlab="weight", ylab="height", lab="");
    for row in eachrow(samples)
        y = row.α .+ row.β .* (dat.weight .- mean(dat.weight))
        plot!(p_new, dat.weight, y, alpha=0.1, color="#000000", lab="",
              title = "N = $N")
    end
    return(p_new)
end

p_10 = make_plot(howell_10, samples_N10, 10)
p_50 = make_plot(howell_50, samples_N50, 50)
p_150 = make_plot(howell_150, samples_N150, 150)
p_all = make_plot(howell, samples_N_all, 352)

figure_4_7 = plot(p_10, p_50, p_150, p_all, layout = (2,2));

avefig(p, joinpath(@OUTPUT, "figure_4_7.svg")); #src

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
