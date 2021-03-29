# This file was generated, do not modify it. # hide
basis_matrix = basismatrix(B, cherry_dat.year)

m4_7_model = m4_7(cherry_dat.doy, basis_matrix)
m4_7_chains = sample(m4_7_model, NUTS(0.65), 1000)

m4_7_res = DataFrame(m4_7_chains)[:, Between(15, 33)]
optimal = optimize(m4_7_model, MAP())

p2 = plot()
for i in 2:18
    plot!(p2, cherry_dat.year, basis_matrix[:,i-1] .* optimal.values[i])
end;

plot(p2, lab = "", xlab = "year", ylab = "basis * weight");