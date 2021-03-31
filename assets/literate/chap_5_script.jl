# This file was generated, do not modify it.

include("src/load_packages.jl");
include("_literate/chap_5_models.jl");
Random.seed!(77);

data_path = joinpath(TuringModels.project_root, "data", "WaffleDivorce.csv")
waffle = CSV.read(data_path, DataFrame; delim=';')
first(waffle, 5)

figure_5_1 = scatter(waffle.WaffleHouses, waffle.Divorce, lab = "", markersize = 4,
                     xlab = "Waffle houses per million", ylab = "Divorce Rate")
loc_array = ["ME", "OK", "AR", "AL", "SC", "GA", "NJ"]
loc_id = findall(x -> x in loc_array, waffle.Loc)
waffle.Loc_annot .= " "
waffle.Loc_annot[loc_id] .= loc_array
annot = Array(tuple.(waffle.WaffleHouses.+5, waffle.Divorce,
                     text.(waffle.Loc_annot, :left, 9)))
annotate!(figure_5_1, annot);

savefig(figure_5_1, joinpath(@OUTPUT, "figure_5_1.svg")); #src

