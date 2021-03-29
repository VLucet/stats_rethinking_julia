# This file was generated, do not modify it. # hide
m4_6_model = m4_6(howell_all.height, howell_all.weight_s, howell_all.weight_s2, howell_all.weight_s3)
m4_6_chains = sample(m4_6_model, NUTS(0.65), 1000)

m4_6_chains_plot = plot(m4_6_chains);
savefig(m4_6_chains_plot, joinpath(@OUTPUT, "m4_6_plot.svg")); #src