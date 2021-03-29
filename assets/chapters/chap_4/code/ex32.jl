# This file was generated, do not modify it. # hide
data_path = joinpath(TuringModels.project_root, "data", "cherry_blossoms.csv")
cherry = CSV.read(data_path, DataFrame; delim=';', missingstrings=["NA"])

cherry_dat = cherry[: , [:year, :doy]]
cherry_dat = cherry_dat[completecases(cherry_dat) , :];