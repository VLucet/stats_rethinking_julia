<!--This file was generated, do not modify it.-->
We start first by including the models needed to run the code for this chapter

```julia:ex1
include("src/load_packages.jl");
include("src/models/chap_4_models.jl");
```

### Importing data

Here we use the Howell dataset.

```julia:ex2
data_path = joinpath(TuringModels.project_root, "data", "Howell1.csv")
howell = CSV.read(data_path, DataFrame; delim=';')
howell = filter(row -> row.age >= 18, howell)
first(howell, 5)
```

### m4.1

We condition the model on the height data, then use the NUTS sampler to
produce a single chain.

```julia:ex3
m4_1_model = m4_1(howell.height)
m4_1_chains = sample(m4_1_model, NUTS(0.65), 1000)
m4_1_chains_plot = plot(m4_1_chains)
savefig(m4_1_chains_plot, joinpath(@OUTPUT, "m4_1_plot.svg")); #src
```

\figalt{Chains for model 4_1}{m4_1_plot.svg}

We can use `optimize()` in combination with `MAP()` to find the MAP, and
we can print the variance-covariance matrix, just like in the book.

```julia:ex4
m4_1_map_estimate = optimize(m4_1_model, MAP())
vcov(m4_1_map_estimate)
```

### m4.2

We conduct a similar analysis for the second model which uses a different
prior on μ.

```julia:ex5
m4_2_model = m4_2(howell.height)
m4_2_chains = sample(m4_2_model, NUTS(0.65), 1000)
m4_2_chains_plot =plot(m4_2_chains)
savefig(m4_2_chains_plot, joinpath(@OUTPUT, "m4_2_plot.svg")); #src
```

\figalt{Chains for model 4_2}{m4_2_plot.svg}

Similarly we get the MAP and the variance-covariance matrix.

```julia:ex6
m4_2_map_estimate = optimize(m4_2_model, MAP())
vcov(m4_2_map_estimate)
```

### m4.3

In what follows, we use two different models that only differs by their
prior for β, in the goal of reproduction **figure 4.5 (page 95)**. We first
condition the models on the data. Here the missing argument has to do with
centering of the value and is useful for later when we use the model for
predictions.

```julia:ex7
m4_3_model = m4_3(howell.height, howell.weight, missing)
m4_3_2_model = m4_3_2(howell.height, howell.weight, missing);
```

#### Prior predictive check

We draw 100 samples from the Prior distributions.

```julia:ex8
m4_3_chains_prior = sample(m4_3_model, Prior(), 100)
m4_3_2_chains_prior = sample(m4_3_2_model, Prior(), 100);
```

We can now reproduce the figure, first with the left plot for the first prior.

```julia:ex9
xi = minimum(howell.weight):0.1:maximum(howell.weight)
p = plot();

for row in 1:length(m4_3_chains_prior)
    yi = m4_3_chains_prior[:α][row] .+ m4_3_chains_prior[:β][row] .* (xi .- mean(howell.weight))
    plot!(p, xi, yi, alpha=0.3, color="#000000", lab="")
end

hline!(p, [0], ls=:dash, color="#000000", lab="");
hline!(p, [272], color="#000000", lab="");
plot!(p, ylims = [-100, 400], title="log(b) ~ N(0, 1)", xlab="weight", ylab="height", lab="");
```

Then with the right plot for the other prior.

```julia:ex10
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
```

\figalt{}{figure_4_5.svg}

#### Sampling

We can now move onto sampling the posterior. Note that the following code
samples only one chain using a NUTS sampler, but Turing has other samplers,
for instance the `MCMC()` sampler, and can be used as such:
`m4_3_chains = sample(m4_3_model, NUTS(), MCMCThreads(), 1000, 4)` (this
samples 4 chains).

```julia:ex11
m4_3_chains = sample(m4_3_model, NUTS(0.65), 1000)
m4_3_chains_plot = plot(m4_3_chains)
savefig(m4_3_chains_plot, joinpath(@OUTPUT, "m4_3_plot.svg")); #src
```

\figalt{Chains for model 4_3}{m4_3_plot.svg}

```julia:ex12
m4_3_map_estimate = optimize(m4_3_model, MAP())
vcov(m4_3_map_estimate)
```

Here is a plot of the data, similar to **figure 4.6 (page 101)**.

```julia:ex13
p = scatter(howell.weight, howell.height, xlab="weight", ylab="height", lab="");
savefig(p, joinpath(@OUTPUT, "figure_4_6.svg")); #src
```

\figalt{}{figure_4_6.svg}

We can use our posterior samples for credible height nad reproduce the **left
panel of **figure 4.9 (page 106)**.

```julia:ex14
for row in 1:length(m4_3_chains)
    yi = m4_3_chains[:α][row] .+ m4_3_chains[:β][row] .* (xi .- mean(howell.weight))
    plot!(p, xi, yi, alpha=0.01, color="#000000", lab="");
end

savefig(p, joinpath(@OUTPUT, "figure_4_9_a.svg")); #src
```

\figalt{}{figure_4_9_a.svg}

#### Compatibility interval

To produce a Compatibility interval, I copied code from this
[stackoverflow question](https://stackoverflow.com/questions/62028147/plotting-
credible-intervals-in--from-turing-model).

```julia:ex15
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
```

\figalt{}{figure_4_9_b.svg}

#### Prediction interval

The prediction interval is a little trickier as it requires to set an empty
vector in lieu of the weight data. We this we can reproduce **figure 4.10
(page 109)**.

```julia:ex16
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
```

\figalt{}{figure_4_10.svg}

