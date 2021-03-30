<!--This file was generated, do not modify it.-->
We start first by including the models needed to run the code for this chapter
and by setting the seed.

```julia:ex1
include("src/load_packages.jl");
include("_literate/chap_5_models.jl");
Random.seed!(77);
```

## Figure 5.1

We first load the waffle data.

```julia:ex2
data_path = joinpath(TuringModels.project_root, "data", "WaffleDivorce.csv")
waffle = CSV.read(data_path, DataFrame; delim=';')
first(waffle, 5)
```

This first figure is a simple plot, I did not bother running the regression
however.

```julia:ex3
scatter(waffle.WaffleHouses, waffle.Divorce, lab = "", markersize = 4,
        xlab = "Waffle houses per million", ylab = "Divorce Rate")
annot = Array(tuple.(waffle.WaffleHouses.+5, waffle.Divorce,
                     text.(waffle.Loc, :left, 9)))
annotate!(annot)
```

