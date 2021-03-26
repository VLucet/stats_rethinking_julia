chap_*.html: chap_*.jmd chap_*_models.jl
	julia --project -e 'using Weave; weave.(filter(x->endswith(x, ".jmd"), readdir(".")), fig_path="plots")'