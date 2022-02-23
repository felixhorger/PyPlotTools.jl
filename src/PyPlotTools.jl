
module PyPlotTools

	import PyCall
	import PyPlot as plt

	function __init__()
		global mpl_axes_grid = PyCall.pyimport("mpl_toolkits.axes_grid1")
		global rcParams = PyCall.PyDict(plt.matplotlib."rcParams")
	end

	function default(key, value)
		rcParams[key] = value
	end

	function activate_eps_output()
		plt.ioff()
		rcParams["lines.linewidth"] = 2
		rcParams["lines.markeredgewidth"] = 1.5
		rcParams["text.usetex"] = true
		rcParams["font.family"] = "serif"
		rcParams["font.serif"] = "Computer Modern"
		rcParams["backend"] = "ps"
	end
	
	function add_colourbar(fig, ax, image; kwargs...)
		divider = axes_grid.make_axes_locatable(ax)
		cax = divider.new_vertical(size="5%", pad=0.05, pack_start=true) # Also: .append
		fig.add_axes(cax)
		colorbar = plt.colorbar(image, cax=cax; kwargs...)
		return cax, colorbar
	end

end

