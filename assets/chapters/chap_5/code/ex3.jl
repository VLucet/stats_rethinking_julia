# This file was generated, do not modify it. # hide
scatter(waffle.WaffleHouses, waffle.Divorce, lab = "", markersize = 4,
        xlab = "Waffle houses per million", ylab = "Divorce Rate")
annot = Array(tuple.(waffle.WaffleHouses.+5, waffle.Divorce,
                     text.(waffle.Loc, :left, 9)))
annotate!(annot)