# This file was generated, do not modify it. # hide
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