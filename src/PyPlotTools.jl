
module PyPlotTools

	import PyCall
	import PyPlot as plt

	const latex_column = 6.52437527778 # inches
	# use \usepackage{layouts} and \printinunitsof{in}\prntlen{\columnwidth} in latex to debug

	function __init__()
		global mpl_axes_grid = PyCall.pyimport("mpl_toolkits.axes_grid1")
		global rcParams = PyCall.PyDict(plt.matplotlib."rcParams")
		rcParams["image.interpolation"] = "none"
		rcParams["image.origin"] = "lower"
		rcParams["image.resample"] = false
		rcParams["text.latex.preamble"] = """
			\\usepackage{amsmath}
			\\usepackage{amssymb}
			\\usepackage{bm}
			\\usepackage[per-mode=symbol]{siunitx}
			\\DeclareSIUnit\\pixel{px}
		"""
		# TODO: Need to put this in config file ...
		rcParams["savefig.bbox"] = "tight"
		set_interactive()
		return
	end

	function set_interactive()
		plt.ion()
		rcParams["lines.linewidth"] = 1
		rcParams["lines.markeredgewidth"] = 1
		rcParams["text.usetex"] = false
		rcParams["font.family"] = "sans-serif"
		rcParams["font.serif"] = "DejaVu Serif"
		rcParams["backend"] = "qt5agg"
		rcParams["figure.subplot.left"] = 0.1
		rcParams["figure.subplot.right"] = 0.9
		rcParams["figure.subplot.bottom"] = 0.1
		rcParams["figure.subplot.top"] = 0.9
		return
	end

	function set_image(backend::String="ps")
		plt.ioff()
		rcParams["lines.linewidth"] = 1
		rcParams["lines.markeredgewidth"] = 1.0
		rcParams["lines.markersize"] = 3.0
		rcParams["text.usetex"] = true
		rcParams["font.family"] = "serif"
		rcParams["font.serif"] = "Computer Modern"
		plt.matplotlib.cm.viridis.set_bad("w", 1)
		rcParams["backend"] = backend
		rcParams["figure.subplot.left"] = 0
		rcParams["figure.subplot.right"] = 1
		rcParams["figure.subplot.bottom"] = 0
		rcParams["figure.subplot.top"] = 1
		return
	end

	function add_colourbar(fig, ax, image; size="5%", pad=0.05, horizontal=false, phantom=false, pack_start=false, kwargs...)
		divider = mpl_axes_grid.make_axes_locatable(ax)
		if horizontal
			cax = divider.new_vertical(;size, pad, pack_start) # Also: .append
			orientation = "horizontal"
			pack_start=false
		else
			cax = divider.new_horizontal(;size, pad, pack_start)
			orientation = "vertical"
		end
		fig.add_axes(cax)
		if phantom
			cax.axis("off")
			return cax, nothing
		end
		colourbar = plt.colorbar(image; cax, orientation, kwargs...)
		if horizontal
			if !pack_start
				# Set ticks to top since it makes more sense to look at the colourbar
				# first because looking at the image (What am I looking at?)
				cax.xaxis.set_tick_params(top=true, bottom=false, labeltop=true, labelbottom=false)
				cax.xaxis.set_label_position("top")
			end
		else
			# TODO rotate label
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

	function get_plot_colour_line(plot, type::Symbol; kwargs...)
		if type == :violin
			colour = vec(plot["bodies"][1].get_facecolor())
		else
			error("Unknown plot type")
		end
		patch = plt.matplotlib.lines.Line2D([], []; color=colour, kwargs...)
		return patch
	end

	transpose_subplots(axs) = [axs[i, j] for j = 1:size(axs, 2), i = 1:size(axs, 1)]

	#function add_text(ax, m, vmin, vminround)
	#	for i in axes(m, 1), j in axes(m, 2)
	#		if m[i, j] > vmin
	#			color = "black"
	#		else
	#			color = "white"
	#		end
	#		rounded = round(m[i, j], digits=1)
	#		if rounded < vminround # %
	#			ax.text(j, i, "$rounded"; fontsize=8, color, va="center", ha="center")
	#		else
	#			ax.text(j, i, "$(round(Int, m[i, j]))"; fontsize=8, color, va="center", ha="center")
	#		end
	#	end
	#end

end

#arrs = (
#	("Fourier", overlap_Fourier),
#	("Jiang", overlap_Jiang),
#	("Zhao", overlap_Zhao),
#	("Koolstra", overlap_Koolstra),
#	("Fast cycle", overlap_Felix)
#)
#fig, axs = plt.subplots(2, 5; sharex="col", sharey="row", figsize=(PyPlotTools.latex_column, 1.2))
#plt.subplots_adjust(left=0, right=1, wspace=0.2, hspace=0.1)
#xticks = (
#	[1, 450, 900],
#	[1, 500, 1000],
#	[1, 200, 400],
#	[1, 100, 240],
#	[1, 400, 840],
#)
#d = 0.5
#broken_kwargs = Dict(
#	:marker => [(-1, -d), (1, d)],
#	:markersize => 5,
#	:linestyle => "none",
#	:color => "k",
#	:mec => "k",
#	:mew => 1,
#	:clip_on => false
#)
#for (i, (title, a)) in enumerate(arrs)
#	axs[1, i].spines["bottom"].set_visible(false)
#	axs[2, i].spines["top"].set_visible(false)
#	amin, imin = findmin(a[2])
#	axs[1, i].tick_params(bottom=false)
#	axs[1, i].set_ylim([1e12, 1e20])
#	axs[2, i].set_ylim([1, 1e6])
#	num_time = length(a[2])
#	for l = 1:2, j = 1:5
#		axs[l, i].plot(1:num_time, a[1]; color="tab:blue", zorder=1)
#		axs[l, i].plot(1:num_time, a[2]; color="tab:orange", zorder=1)
#		axs[l, i].set_yscale("log")
#		axs[l, i].axvline(floor.(Int, range(1, num_time; length=6+1)[1:5])[j]; zorder=0, color="tab:green", linestyle="dashed", linewidth=0.75)
#		#axs[l, i].plot(imin, amin, "o"; markeredgewidth=0.75, markersize=3, color="tab:red")
#	end
#	axs[1, i].set_title(title; fontdict=Dict("fontsize"=>10))
#	axs[2, i].set_xticks(xticks[i])
#	axs[2, i].set_xlabel("\$t\$ [index]"; fontdict=Dict("fontsize"=>10))
#	axs[1, i].plot([0, 1], [0, 0], transform=axs[1, i].transAxes; broken_kwargs...)
#	axs[2, i].plot([0, 1], [1, 1], transform=axs[2, i].transAxes; broken_kwargs...)
#end
#axs[1, 1].set_ylabel("Condition number")
#plt.savefig("conditioning_sampling.eps")
#plt.close(fig)
