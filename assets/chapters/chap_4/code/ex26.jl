# This file was generated, do not modify it. # hide
m4_5_model = m4_5(howell_all.height, howell_all.weight_s, howell_all.weight_s2)
m4_5_chains = sample(m4_5_model, NUTS(0.65), 1000)

m4_5_chains_plot = plot(m4_5_chains);
savefig(m4_5_chains_plot, joinpath(@OUTPUT, "m4_5_plot.svg")); #src