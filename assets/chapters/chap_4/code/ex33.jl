# This file was generated, do not modify it. # hide
num_knots = 15
knot_list = quantile(cherry_dat.year, Weights(range(0, 1, length = num_knots)))
B = BSplineBasis(4, knot_list);