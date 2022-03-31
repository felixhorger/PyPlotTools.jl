
module PyPlotTools

	import PyCall
	import PyPlot as plt

	const latex_column = 6.52437527778 # inches

	function __init__()
		global mpl_axes_grid = PyCall.pyimport("mpl_toolkits.axes_grid1")
		global rcParams = PyCall.PyDict(plt.matplotlib."rcParams")
		rcParams["image.interpolation"] = "none"
		rcParams["image.origin"] = "lower"
		rcParams["image.resample"] = false
		rcParams["savefig.bbox"] = "tight"
		return
	end

	function set_interactive()
		plt.ion()
		rcParams["lines.linewidth"] = 1
		rcParams["lines.markeredgewidth"] = 1
		rcParams["text.usetex"] = false
		rcParams["font.family"] = "sans-serif"
		rcParams["backend"] = "qt5agg"
		rcParams["figure.subplot.left"] = 0.1
		rcParams["figure.subplot.right"] = 0.9
		rcParams["figure.subplot.bottom"] = 0.1
		rcParams["figure.subplot.top"] = 0.9
		return
	end

	function set_eps()
		plt.ioff()
		rcParams["lines.linewidth"] = 2
		rcParams["lines.markeredgewidth"] = 1.25
		rcParams["text.usetex"] = true
		rcParams["font.family"] = "serif"
		rcParams["font.serif"] = "Computer Modern"
		plt.matplotlib.cm.viridis.set_bad("w", 1)
		rcParams["backend"] = "ps"
		rcParams["figure.subplot.left"] = 0
		rcParams["figure.subplot.right"] = 1
		rcParams["figure.subplot.bottom"] = 0
		rcParams["figure.subplot.top"] = 1
		return
	end
	
	function add_colourbar(fig, ax, image; size="5%", pad=0.05, kwargs...)
		divider = mpl_axes_grid.make_axes_locatable(ax)
		horizontal = false
		if haskey(kwargs, :orientation) && kwargs[:orientation] == "horizontal"
			cax = divider.new_vertical(;size, pad, pack_start=false) # Also: .append
			horizontal = true
		else
			cax = divider.new_horizontal(;size, pad, pack_start=false) 
		end
		fig.add_axes(cax)
		colourbar = plt.colorbar(image, cax=cax; kwargs...)
		if horizontal
			# Set ticks to top since it makes more sense to look at the colourbar
			# first because looking at the image (What am I looking at?)
			cax.xaxis.set_tick_params(top=true, bottom=false, labeltop=true, labelbottom=false)
			cax.xaxis.set_label_position("top")
		end
		return cax, colourbar
	end

	function add_roi(ax, roi::NTuple{2, AbstractRange}; linewidth=1, edgecolor="r", facecolor="none")
		ax.add_patch(
			plt.matplotlib[:patches][:Rectangle](
				(roi[2].start - 1, roi[1].start - 1),
				roi[2].stop - roi[2].start,
				roi[1].stop - roi[1].start;
				transform=ax.transData,
				linewidth, edgecolor, facecolor
			)
		)
	end

end

