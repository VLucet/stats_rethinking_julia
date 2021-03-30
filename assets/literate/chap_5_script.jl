# This file was generated, do not modify it.

include("src/load_packages.jl");
include("_literate/chap_5_models.jl");
Random.seed!(77);

data_path = joinpath(TuringModels.project_root, "data", "WaffleDivorce.csv")
waffle = CSV.read(data_path, DataFrame; delim=';')
first(waffle, 5)

scatter(waffle.WaffleHouses, waffle.Divorce, lab = "", markersize = 4,
        xlab = "Waffle houses per million", ylab = "Divorce Rate")
annot = Array(tuple.(waffle.WaffleHouses.+5, waffle.Divorce,
                     text.(waffle.Loc, :left, 9)))
annotate!(annot)

