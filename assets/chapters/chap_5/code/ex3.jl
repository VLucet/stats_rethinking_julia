# This file was generated, do not modify it. # hide
figure_5_1 = scatter(waffle.WaffleHouses, waffle.Divorce, lab = "", markersize = 4,
                     xlab = "Waffle houses per million", ylab = "Divorce Rate")
loc_array = ["ME", "OK", "AR", "AL", "SC", "GA", "NJ"]
loc_id = findall(x -> x in loc_array, waffle.Loc)
waffle.Loc_annot = [" " for i in 1:length(waffle.Loc)]
waffle.Loc_annot[loc_id] .= loc_array
annot = Array(tuple.(waffle.WaffleHouses.+5, waffle.Divorce,
                     text.(waffle.Loc_annot, :left, 9)))
annotate!(figure_5_1, annot);

savefig(figure_5_1, joinpath(@OUTPUT, "figure_5_1.svg")); #src