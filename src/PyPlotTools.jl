
module PyPlotTools

	import PyCall
	import PyPlot as plt

	function __init__()
		global mpl_axes_grid = PyCall.pyimport("mpl_toolkits.axes_grid1")
		global rcParams = PyCall.PyDict(plt.matplotlib."rcParams")
		rcParams["image.interpolation"] = "none"
		return
	end

	function set_interactive()
		plt.ion()
		rcParams["lines.linewidth"] = 1
		rcParams["lines.markeredgewidth"] = 1
		rcParams["text.usetex"] = false
		rcParams["font.family"] = "sans-serif"
		rcParams["backend"] = "qt5agg"
		return
	end

	function set_eps()
		plt.ioff()
		rcParams["lines.linewidth"] = 2
		rcParams["lines.markeredgewidth"] = 1.5
		rcParams["text.usetex"] = true
		rcParams["font.family"] = "serif"
		rcParams["font.serif"] = "Computer Modern"
		rcParams["backend"] = "ps"
		return
	end
	
	function add_colourbar(fig, ax, image; size="5%", pad=0.05, kwargs...)
		divider = mpl_axes_grid.make_axes_locatable(ax)
		if haskey(kwargs, :orientation) && kwargs[:orientation] == "horizontal"
			cax = divider.new_vertical(;size, pad, pack_start=true) # Also: .append
		else
			cax = divider.new_horizontal(;size, pad, pack_start=false) 
		end
		fig.add_axes(cax)
		colorbar = plt.colorbar(image, cax=cax; kwargs...)
		return cax, colorbar
	end

end

