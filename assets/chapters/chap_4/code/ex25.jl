# This file was generated, do not modify it. # hide
howell_all = CSV.read(data_path, DataFrame; delim=';');
howell_all.weight_s = (howell_all.weight .- mean(howell_all.weight))./std(howell_all.weight)
howell_all.weight_s2 = howell_all.weight_s.^2
howell_all.weight_s3 = howell_all.weight_s.^3;