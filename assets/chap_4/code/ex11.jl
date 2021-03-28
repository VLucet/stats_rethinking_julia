# This file was generated, do not modify it. # hide
m4_2_model = m4_2(howell.height)
m4_2_chains = sample(m4_2_model, NUTS(0.65), 1000)
m4_2_chains_plot =plot(m4_2_chains)
savefig(m4_2_chains_plot, joinpath(@OUTPUT, "m4_2_plot.svg")); #src