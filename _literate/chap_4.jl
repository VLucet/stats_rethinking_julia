# We start first by including the models needed to run the code for this chapter
# and by setting the seed.
include("src/load_packages.jl");
include("_literate/chap_4_models.jl");
Random.seed!(77);

# ## Figure 4.2

# In Julia, we rely on the package `Distributions.jl` to sample from a given 
# distribution. Here we sample 16 times from a uniform distribution U ~ (-1, 1).
# We now plot the bottom part of **figure 4.2 (page 73)**.

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

# Now for the top part of the plot.

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

# \figalt{}{figure_4_2.svg}

# ## Figure 4.3

# ### Importing data
# 
# For the rest of the chapter, we use the Howell dataset.

data_path = joinpath(TuringModels.project_root, "data", "Howell1.csv")
howell = CSV.read(data_path, DataFrame; delim=';')
howell = filter(row -> row.age >= 18, howell)
first(howell, 5)

# ### Prior predictive simulation

# It is good to visualize the priors we choose for a given analysis. Here we 
# plot them to reproduce **figure 4.3 (page 83)**.

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

# \figalt{}{figure_4_3.svg}

# ## Figure 4.4

# ### Posterior grid approximation

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

# We can make a contour plot of the posterior: 

contour_plot = contour(μ_vec, σ_vec, post_prob)
savefig(contour_plot, joinpath(@OUTPUT, "contour_plot.svg")); #src 

# \figalt{}{contour_plot.svg}

# Let's now sample from that posterior

sample_rows = sample(collect(1:size(post_grid)[1]), Weights(post_prob), 
                     10_000, replace = true)
sample_μ = all_μ[sample_rows]
sample_σ = all_σ[sample_rows]

figure_4_4 = scatter(sample_μ, sample_σ, lab = "", aspect_ratio = 1.5,
                     xlab = "μ", ylab = "σ", markeralpha=0.1, markersize=3);

savefig(figure_4_4, joinpath(@OUTPUT, "figure_4_4.svg")); #src 

# \figalt{}{figure_4_4.svg}

# ## Figure 4.5

# We now condition the model on the height data, then use the NUTS sampler to 
# produce a single chain.

m4_1_model = m4_1(howell.height)
m4_1_chains = sample(m4_1_model, NUTS(0.65), 1000)
m4_1_chains_plot = plot(m4_1_chains)
savefig(m4_1_chains_plot, joinpath(@OUTPUT, "m4_1_plot.svg")); #src 

# \figalt{Chains for model 4_1}{m4_1_plot.svg}

# We can use `optimize()` in combination with `MAP()` to find the MAP, and 
# we can print the variance-covariance matrix, just like in the book.

m4_1_map_estimate = optimize(m4_1_model, MAP())
vcov(m4_1_map_estimate)

# ### m4.2
#
# We conduct a similar analysis for the second model which uses a different
# prior on μ.

m4_2_model = m4_2(howell.height)
m4_2_chains = sample(m4_2_model, NUTS(0.65), 1000)
m4_2_chains_plot =plot(m4_2_chains)
savefig(m4_2_chains_plot, joinpath(@OUTPUT, "m4_2_plot.svg")); #src 

# \figalt{Chains for model 4_2}{m4_2_plot.svg}

# Similarly we get the MAP and the variance-covariance matrix.

m4_2_map_estimate = optimize(m4_2_model, MAP())
vcov(m4_2_map_estimate)

# In what follows, we use two different models that only differs by their 
# prior for β, in the goal of reproduction **figure 4.5 (page 95)**. We first
# condition the models on the data. Here the missing argument has to do with 
# centering of the value and is useful for later when we use the model for
# predictions.

m4_3_model = m4_3(howell.height, howell.weight, missing)
m4_3_2_model = m4_3_2(howell.height, howell.weight, missing);

# #### Prior predictive check

# We draw 100 samples from the Prior distributions.

m4_3_chains_prior = sample(m4_3_model, Prior(), 100)
m4_3_2_chains_prior = sample(m4_3_2_model, Prior(), 100);

# We can now reproduce the figure, first with the left plot for the first prior.

xi = minimum(howell.weight):0.1:maximum(howell.weight)

p = plot();

for row in 1:length(m4_3_chains_prior)
    yi = m4_3_chains_prior[:α][row] .+ m4_3_chains_prior[:β][row] .* (xi .- mean(howell.weight))
    plot!(p, xi, yi, alpha=0.3, color="#000000", lab="")
end

hline!(p, [0], ls=:dash, color="#000000", lab="");
hline!(p, [272], color="#000000", lab="");
plot!(p, ylims = [-100, 400], title="log(b) ~ N(0, 1)", xlab="weight", ylab="height", lab="");

# Then with the right plot for the other prior.

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

# \figalt{}{figure_4_5.svg}

# ## Figure 4.6

# #### Sampling

# We can now move onto sampling the posterior. Note that the following code 
# samples only one chain using a NUTS sampler, but Turing has other samplers, 
# for instance the `MCMC()` sampler, and can be used as such:
# `m4_3_chains = sample(m4_3_model, NUTS(), MCMCThreads(), 1000, 4)` (this 
# samples 4 chains).

m4_3_chains = sample(m4_3_model, NUTS(0.65), 1000)
m4_3_chains_plot = plot(m4_3_chains)
savefig(m4_3_chains_plot, joinpath(@OUTPUT, "m4_3_plot.svg")); #src 

# \figalt{Chains for model 4_3}{m4_3_plot.svg}

m4_3_map_estimate = optimize(m4_3_model, MAP())
vcov(m4_3_map_estimate)

# Here is a plot of the data, similar to **figure 4.6 (page 101)**. 

p = scatter(howell.weight, howell.height, xlab="weight", ylab="height", lab="");
savefig(p, joinpath(@OUTPUT, "figure_4_6.svg")); #src 

# \figalt{}{figure_4_6.svg}

# ## Figure 4.7

# For this figure we plot an increasing number of points to show the uncertainty
# decreasing as N increases.

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

# \figalt{}{figure_4_7.svg}

# ## Figure 4.8

# We plot the posterior of height for weight = 50.
μ_at_50 = samples_N_all.α .+ samples_N_all.β .* (50 - mean(howell.weight))

figure_4_8 = density(μ_at_50, xlab="μ | weight = 50", ylab="Density", lab="");

savefig(figure_4_8, joinpath(@OUTPUT, "figure_4_8.svg")); #src 

# \figalt{}{figure_4_8.svg}

# ## Figure 4.9

# We can use our posterior samples for credible height nad reproduce the **left 
# panel of **figure 4.9 (page 106)**.

p = scatter(howell.weight, howell.height, xlab="weight", ylab="height", lab="")

for row in 1:length(m4_3_chains)
    yi = m4_3_chains[:α][row] .+ m4_3_chains[:β][row] .* (xi .- mean(howell.weight))
    plot!(p, xi, yi, alpha=0.01, color="#000000", lab="");
end

savefig(p, joinpath(@OUTPUT, "figure_4_9_a.svg")); #src 

# \figalt{}{figure_4_9_a.svg}

# #### Compatibility interval

# To produce a Compatibility interval, I copied code from this 
# [stackoverflow question](https://stackoverflow.com/questions/62028147/plotting-
# credible-intervals-in--from-turing-model).

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

# \figalt{}{figure_4_9_b.svg}

# ## Figure 4.10

# #### Prediction interval

# The prediction interval is a little trickier as it requires to set an empty
# vector in lieu of the weight data. We this we can reproduce **figure 4.10 
# (page 109)**.

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

predict_interval_4_3 = predict_interval(0.1, 0.9, m4_3_test, m4_3_chains, "height")

p3 = scatter(howell.weight, howell.height, lab="")
plot!(p3, xi, compat_interval_4_3[2], 
      ribbon = [compat_interval_4_3[1], compat_interval_4_3[3]], lab="")
plot!(p3, x_pred, predict_interval_4_3[2], 
      ribbon = [predict_interval_4_3[1], predict_interval_4_3[3]], 
      xlab="weight", ylab="height", lab="")

savefig(p3, joinpath(@OUTPUT, "figure_4_10.svg")); #src 

# \figalt{}{figure_4_10.svg}

# ## Figure 4.11

# For what follows, let's reload the data with all rows. We also standardize 
# weights and create polynomial variables for weights.

howell_all = CSV.read(data_path, DataFrame; delim=';');
howell_all.weight_s = (howell_all.weight .- mean(howell_all.weight))./std(howell_all.weight)
howell_all.weight_s2 = howell_all.weight_s.^2
howell_all.weight_s3 = howell_all.weight_s.^3;

# We can now condition the model on data and sample.

m4_5_model = m4_5(howell_all.height, howell_all.weight_s, howell_all.weight_s2)
m4_5_chains = sample(m4_5_model, NUTS(0.65), 1000)

m4_5_chains_plot = plot(m4_5_chains);
savefig(m4_5_chains_plot, joinpath(@OUTPUT, "m4_5_plot.svg")); #src 

# \figalt{Chains for model 4_5}{m4_5_plot.svg}

# Similarly for the cubic model:

m4_6_model = m4_6(howell_all.height, howell_all.weight_s, howell_all.weight_s2, howell_all.weight_s3)
m4_6_chains = sample(m4_6_model, NUTS(0.65), 1000)

m4_6_chains_plot = plot(m4_6_chains);
savefig(m4_6_chains_plot, joinpath(@OUTPUT, "m4_6_plot.svg")); #src 

# \figalt{Chains for model 4_6}{m4_6_plot.svg}

# To reproduce **figure 4.11 (page112)**, we need to repeat the process for 
# figure 4.10. We start with the linear model for all the data.

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

# Now the square model. 
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

# Finally the cubic model. 

res_4_6 = DataFrame(m4_6_chains)

function m4_6_model_eq(weight, weight_squared, weight_cubed, α, β1, β2, β3)
    height = α + β1 * weight + β2 * weight_squared + β3 * weight_cubed
end

arr_4_6 = [m4_6_model_eq.(w, w_2, w_3, res_4_6.α, 
                              res_4_6.β1, res_4_6.β2, res_4_6.β3) 
             for (w, w_2, w_3) in zip(xi_s, xi_s.^2, xi_s.^3)]
compat_interval_4_6 = compat_interval(0.1, 0.9, arr_4_6)

m4_6_test = m4_6(Vector{Union{Missing, Float64}}(undef, length(x_pred_s)), 
                     vcat(x_pred_s), vcat(x_pred_s.^2), vcat(x_pred_s.^3));
predict_interval_4_6 = predict_interval(0.1, 0.9, m4_6_test, m4_6_chains, "height")

p3 = scatter(howell_all.weight_s, howell_all.height,
             xlab="weight_s", ylab="height", lab="", title = "Cubic")
plot!(p3, xi_s, compat_interval_4_6[2], 
      ribbon = [compat_interval_4_6[1], compat_interval_4_6[3]], lab="")
plot!(p3, x_pred_s, predict_interval_4_6[2], 
      ribbon = [predict_interval_4_6[1], predict_interval_4_6[3]], lab="");

# And we can now assemble the figure.

figure_4_11 = plot(p1, p2, p3, layout = (1, 3));

savefig(figure_4_11, joinpath(@OUTPUT, "figure_4_11.svg")); #src 

# \figalt{}{figure_4_11.svg}

# ## Figure 4.12
# **NOTE:** This fgure is not reproduced on this page.

# ## Figure 4.13

# We know load a different dataset.

data_path = joinpath(TuringModels.project_root, "data", "cherry_blossoms.csv")
cherry = CSV.read(data_path, DataFrame; delim=';', missingstrings=["NA"])

cherry_dat = cherry[: , [:year, :doy]]
cherry_dat = cherry_dat[completecases(cherry_dat) , :];

# We make a spline with 17 basis functions.

num_knots = 15
knot_list = quantile(cherry_dat.year, Weights(range(0, 1, length = num_knots)))
B = BSplineBasis(4, knot_list); 

# We can plot the first part of the figure.

p1 = plot(B, lab = "", xlab = "year", ylab = "basis value");

# Now we evaluate the splines to then fit the weigths.

basis_matrix = basismatrix(B, cherry_dat.year)

m4_7_model = m4_7(cherry_dat.doy, basis_matrix)
m4_7_chains = sample(m4_7_model, NUTS(0.65), 1000)

m4_7_res = Array(DataFrame(m4_7_chains)[:, Between(15, 33)])
optimal = optimize(m4_7_model, MAP())

p2 = plot()
for i in 2:18
    plot!(p2, cherry_dat.year, basis_matrix[:,i-1] .* optimal.values[i])
end;

plot(p2, lab = "", xlab = "year", ylab = "basis * weight");

# Now , the last part of the figure.

function m4_7_model_eq(α, mat_basis, w)
    D = α .+ mat_basis * w
end

arr_4_7 = [m4_7_model_eq(m4_7_res[i,18], basis_matrix, m4_7_res[i,1:17]) 
           for i in 1:size(m4_7_res, 1)]
mat_4_7 = reduce(hcat, arr_4_7)

mean_vector = [mean(mat_4_7[i,:]) for i in 1:size(mat_4_7, 1)]
quantiles = [quantile(mat_4_7[i,:], [0.1, 0.9]) for i in 1:size(mat_4_7, 1)]
lower = [q[1] - m for (q, m) in zip(quantiles, mean_vector)]
upper = [q[2] - m for (q, m) in zip(quantiles, mean_vector)]

p3 = scatter(cherry_dat.year, cherry_dat.doy, alpha = 0.2, lab = "")
spline = optimal.values[1] .+ basis_matrix * optimal.values[2:18]
plot!(p3, cherry_dat.year, spline, linewidth=3, lab = "",
      xlab = "year", ylab = "Day in year")
plot!(p3, cherry_dat.year, mean_vector, 
      ribbon = [lower, upper], lab="", linewidth=0)

figure_4_12 = plot(p1, p2, p3, layout = (3,1));
savefig(figure_4_12, joinpath(@OUTPUT, "figure_4_12.svg")); #src 

# \figalt{}{figure_4_12.svg}