# This file was generated, do not modify it.

include("src/load_packages.jl");
include("_literate/chap_4_models.jl");
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

savefig(figure_4_7, joinpath(@OUTPUT, "figure_4_7.svg")); #src

μ_at_50 = samples_N_all.α .+ samples_N_all.β .* (50 - mean(howell.weight))

figure_4_8 = density(μ_at_50, xlab="μ | weight = 50", ylab="Density", lab="");

savefig(figure_4_8, joinpath(@OUTPUT, "figure_4_8.svg")); #src

p = scatter(howell.weight, howell.height, xlab="weight", ylab="height", lab="")

for row in 1:length(m4_3_chains)
    yi = m4_3_chains[:α][row] .+ m4_3_chains[:β][row] .* (xi .- mean(howell.weight))
    plot!(p, xi, yi, alpha=0.01, color="#000000", lab="");
end

savefig(p, joinpath(@OUTPUT, "figure_4_9_a.svg")); #src

res_4_3 = DataFrame(m4_3_chains)

function m4_3_model_eq(weight, α, β, mean_weight)
    height = α + β * (weight .- mean_weight)
end

arr_4_3 = [m4_3_model_eq.(w, res_4_3.α, res_4_3.β, mean(howell.weight)) for w in xi]

function compat_interval(lower_bound, upper_bound, array)
    mean_vector = [mean(v) for v in array]
    quantiles = [quantile(v, [lower_bound, upper_bound]) for v in array]
    lower = [q[1] - m for (q, m) in zip(quantiles, mean_vector)]
    upper = [q[2] - m for (q, m) in zip(quantiles, mean_vector)]
    return lower, mean_vector, upper
end

compat_interval_4_3 = compat_interval(0.1, 0.9, arr_4_3)

p2 = scatter(howell.weight, howell.height, lab="")
plot!(p2, xi, compat_interval_4_3[2],
      ribbon = [compat_interval_4_3[1], compat_interval_4_3[3]],
      xlab="weight", ylab="height", lab="")

savefig(p2, joinpath(@OUTPUT, "figure_4_9_b.svg")); #src

x_pred = xi

m4_3_test = m4_3(Vector{Union{Missing, Float64}}(undef, length(x_pred)),
                 vcat(x_pred), mean(howell.weight));

function predict_interval(lower_bound, upper_bound, test, chains, var)

    preds = predict(test, chains)
    pred_arr = Array(group(preds, var))
    quants_pred = [quantile(col, [lower_bound, upper_bound]) for col in eachcol(pred_arr)]

    m_pred = [mean(v) for v in eachcol(pred_arr)]
    lower_pred = [q[1] - m for (q, m) in zip(quants_pred, m_pred)]
    upper_pred = [q[2] - m for (q, m) in zip(quants_pred, m_pred)]

    return(lower_pred, m_pred, upper_pred)
end

predict_interval_4_3 = predict_interval(m4_3_test, m4_3_chains, "height")

p3 = scatter(howell.weight, howell.height, lab="")
plot!(p3, xi, compat_interval_4_3[2],
      ribbon = [compat_interval_4_3[1], compat_interval_4_3[3]], lab="")
plot!(p3, x_pred, predict_interval_4_3[2],
      ribbon = [predict_interval_4_3[1], predict_interval_4_3[3]],
      xlab="weight", ylab="height", lab="")

savefig(p3, joinpath(@OUTPUT, "figure_4_10.svg")); #src

howell_all = CSV.read(data_path, DataFrame; delim=';');
howell_all.weight_s = (howell_all.weight .- mean(howell_all.weight))./std(howell_all.weight)
howell_all.weight_s2 = howell_all.weight_s.^2
howell_all.weight_s3 = howell_all.weight_s.^3;

m4_5_model = m4_5(howell_all.height, howell_all.weight_s, howell_all.weight_s2)
m4_5_chains = sample(m4_5_model, NUTS(0.65), 1000)

m4_5_chains_plot = plot(m4_5_chains);
savefig(m4_5_chains_plot, joinpath(@OUTPUT, "m4_5_plot.svg")); #src

m4_5_2_model = m4_5_2(howell_all.height, howell_all.weight_s, howell_all.weight_s2, howell_all.weight_s3)
m4_5_2_chains = sample(m4_5_2_model, NUTS(0.65), 1000)

m4_5_2_chains_plot = plot(m4_5_2_chains);
savefig(m4_5_2_chains_plot, joinpath(@OUTPUT, "m4_5_2_plot.svg")); #src

xi_s = minimum(howell_all.weight_s):0.1:maximum(howell_all.weight_s)
x_pred_s = xi_s

m4_3_model_s = m4_3(howell_all.height, howell_all.weight_s, 0)
m4_3_chains_s = sample(m4_3_model_s, NUTS(0.65), 1000)
res_4_3_s = DataFrame(m4_3_chains_s)
arr_4_3_s = [m4_3_model_eq.(w, res_4_3_s.α, res_4_3_s.β, 0) for w in xi_s]

compat_interval_4_3_s = compat_interval(0.1, 0.9, arr_4_3_s)

m4_3_test_s = m4_3(Vector{Union{Missing, Float64}}(undef, length(x_pred_s)),
              vcat(x_pred_s), mean(howell_all.weight_s));
predict_interval_4_3_s = predict_interval(0.1, 0.9, m4_3_test_s, m4_3_chains_s, "height")

p1 = scatter(howell_all.weight_s, howell_all.height,
             xlab="weight_s", ylab="height", lab="", title = "Linear")
plot!(p1, xi_s, compat_interval_4_3_s[2],
      ribbon = [compat_interval_4_3_s[1], compat_interval_4_3_s[3]], lab="")
plot!(p1, x_pred_s, predict_interval_4_3_s[2],
      ribbon = [predict_interval_4_3_s[1], predict_interval_4_3_s[3]], lab="");

res_4_5 = DataFrame(m4_5_chains)

function m4_5_model_eq(weight, weight_squared, α, β1, β2)
    height = α + β1 * weight + β2 * weight_squared
end

arr_4_5 = [m4_5_model_eq.(w, w_2, res_4_5.α, res_4_5.β1, res_4_5.β2)
           for (w, w_2) in zip(xi_s, xi_s.^2)]
compat_interval_4_5 = compat_interval(0.1, 0.9, arr_4_5)

m4_5_test = m4_5(Vector{Union{Missing, Float64}}(undef, length(x_pred_s)),
                 vcat(x_pred_s), vcat(x_pred_s.^2));
predict_interval_4_5 = predict_interval(0.1, 0.9, m4_5_test, m4_5_chains, "height")

p2 = scatter(howell_all.weight_s, howell_all.height,
             xlab="weight_s", ylab="height", lab="", title = "Quadratic")
plot!(p2, xi_s, compat_interval_4_5[2],
      ribbon = [compat_interval_4_5[1], compat_interval_4_5[3]], lab="")
plot!(p2, x_pred_s, predict_interval_4_5[2],
      ribbon = [predict_interval_4_5[1], predict_interval_4_5[3]], lab="");

res_4_5_2 = DataFrame(m4_5_2_chains)

function m4_5_2_model_eq(weight, weight_squared, weight_cubed, α, β1, β2, β3)
    height = α + β1 * weight + β2 * weight_squared + β3 * weight_cubed
end

arr_4_5_2 = [m4_5_2_model_eq.(w, w_2, w_3, res_4_5_2.α,
                              res_4_5_2.β1, res_4_5_2.β2, res_4_5_2.β3)
             for (w, w_2, w_3) in zip(xi_s, xi_s.^2, xi_s.^3)]
compat_interval_4_5_2 = compat_interval(0.1, 0.9, arr_4_5_2)

m4_5_2_test = m4_5_2(Vector{Union{Missing, Float64}}(undef, length(x_pred_s)),
                     vcat(x_pred_s), vcat(x_pred_s.^2), vcat(x_pred_s.^3));
predict_interval_4_5_2 = predict_interval(0.1, 0.9, m4_5_2_test, m4_5_2_chains, "height")

p3 = scatter(howell_all.weight_s, howell_all.height,
             xlab="weight_s", ylab="height", lab="", title = "Cubic")
plot!(p3, xi_s, compat_interval_4_5_2[2],
      ribbon = [compat_interval_4_5_2[1], compat_interval_4_5_2[3]], lab="")
plot!(p3, x_pred_s, predict_interval_4_5_2[2],
      ribbon = [predict_interval_4_5_2[1], predict_interval_4_5_2[3]], lab="");

figure_4_11 = plot(p1, p2, p3, layout = (1, 3));

savefig(figure_4_11, joinpath(@OUTPUT, "figure_4_11.svg")); #src

