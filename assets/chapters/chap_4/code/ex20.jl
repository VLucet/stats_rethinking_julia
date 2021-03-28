# This file was generated, do not modify it. # hide
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