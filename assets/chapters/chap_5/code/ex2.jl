# This file was generated, do not modify it. # hide
data_path = joinpath(TuringModels.project_root, "data", "WaffleDivorce.csv")
waffle = CSV.read(data_path, DataFrame; delim=';')
first(waffle, 5)