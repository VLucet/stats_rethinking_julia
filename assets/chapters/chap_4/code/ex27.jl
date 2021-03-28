# This file was generated, do not modify it. # hide
m4_5_2_model = m4_5_2(howell_all.height, howell_all.weight_s, howell_all.weight_s2, howell_all.weight_s3)
m4_5_2_chains = sample(m4_5_2_model, NUTS(0.65), 1000)

m4_5_2_chains_plot = plot(m4_5_2_chains);
savefig(m4_5_2_chains_plot, joinpath(@OUTPUT, "m4_5_2_plot.svg")); #src