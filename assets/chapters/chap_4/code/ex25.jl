# This file was generated, do not modify it. # hide
howell = CSV.read(data_path, DataFrame; delim=';');
howell.weight_s = (howell.weight .- mean(howell.weight))./std(howell.weight)
howell.weight_s2 = howell.weight_s.^2;