# This file was generated, do not modify it. # hide
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