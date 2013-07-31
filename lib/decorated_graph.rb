require 'prawn'

require_relative 'graph_helper'

# Note: It's not easy to switch font back and forth in prawn pdf, so we keep same font though out the graph.
#       To change font, you can create a pdf, set its font to some font-family, then call raw_graph, 
#       then set font back to default ('Helvetica')

module Prawn
  class DecoratedGraph

	def initialize(pdf, origin2, width, height, data, xlegend=nil, ylegend=nil, top=0, right=0, 
		bottom=0, left=0, outer_color='ffffff', inner_color='ffffff')

	  # sanitizing inputs
	  raise 'origin2 must be an array of two numbers' unless origin2.size == 2 and origin2[0].kind_of? Integer and origin2[1].kind_of? Integer
	  raise 'top must be a positive number' unless top.kind_of? Integer and top >= 0
	  raise 'right must be a positive number' unless right.kind_of? Integer and right >= 0
	  raise 'bottom must be a positive number' unless bottom.kind_of? Integer and bottom >= 0
	  raise 'left must be a positive number' unless left.kind_of? Integer and left >= 0
	  raise 'width must be positive' unless width.kind_of? Integer and width > 0
	  raise 'height must be positive' unless height.kind_of? Integer and height > 0
	  raise 'data must be array of hashes' unless data.kind_of? Array
	  data.each do |series|
		raise 'points must be an array of points' unless series[:points].kind_of? Array
		series[:points].each do |p|
			raise 'point must be an array of two numbers' unless p.size == 2 and p[0].kind_of? Integer and p[1].kind_of? Integer 
		end
		raise 'point_spec must be a hash' unless series[:point_spec].kind_of? Hash
		raise 'line_spec must be a hash' if series[:line_spec] != nil and !series[:line_spec].kind_of? Hash
	  end
	  raise 'xlegend must be a hash' if xlegend != nil and !xlegend.kind_of? Hash
	  raise 'ylegend must be a hash' if ylegend != nil and !ylegend.kind_of? Hash
	  raise 'error for inner graphic width' unless width - left > right
	  raise 'error for inner graphic height' unless ht = height - top > bottom
	  # end of sanitizing

	  @outer_origin = origin2
	  @outer_width = width
	  @outer_height = height
	  @origin = [origin2[0] + left, origin2[1] + bottom]
	  @width = width - left - right
	  @height = height - top - bottom
	  @data = data
	  @xlegend = xlegend
	  @xlegend = {legend_position: 'bottom', xleft_offset: 0, xright_offset:0} unless xlegend
	  @ylegend = ylegend
	  @ylegend = {legend_position: 'left', bottom_offset: 0, top_offset:0} unless ylegend
	  @top = top
	  @right = right
	  @bottom = bottom
	  @left = left
	  @outer_color = outer_color
	  @inner_color = inner_color
	  @pdf = pdf

	  # required default values
	  @xlegend[:xleft_offset] = 0 unless @xlegend[:xleft_offset]
	  @xlegend[:xright_offset] = 0 unless @xlegend[:xright_offset]
	  @xlegend[:y_offset] = -3 unless @xlegend[:y_offset]
	  @xlegend[:legend_color] = '000000' unless @xlegend[:legend_color]
	  @xlegend[:angle] = 0 unless @xlegend[:angle]
	  @ylegend[:top_offset] = 0 unless @ylegend[:top_offset]
	  @ylegend[:bottom_offset] = 0 unless @ylegend[:bottom_offset]
	  @ylegend[:x_offset] = 0 unless @ylegend[:x_offset]
	  @ylegend[:legend_color] = '000000' unless @ylegend[:legend_color]
	  @ylegend[:angle] = 0 unless @ylegend[:angle]

	end

	def draw_graph
	  org_fill = @pdf.fill_color
	  org_stroke = @pdf.stroke_color
	  org_line_width = @pdf.line_width

	  @pdf.fill_color @outer_color
	  @pdf.fill_rectangle([@outer_origin[0], @outer_origin[1] + @outer_height], @outer_width, @outer_height)

	  draw_inner_graph
	  @pdf.fill_color org_fill

	  # Restore org values
	  @pdf.fill_color org_fill
	  @pdf.stroke_color org_stroke
	  @pdf.line_width org_line_width
	end

	def draw_inner_graph
	  org_x = @origin[0]
	  org_y = @origin[1]

	  # draw inner graph area
	  @pdf.stroke_color '000000' if @inner_color == @outer_color
	  @pdf.fill_color = @inner_color
	  @pdf.fill_rectangle [org_x, org_y + @height], @width, @height
	  if @inner_color == @outer_color
	  	@pdf.stroke_color '000000'
	  	@pdf.rectangle [org_x, org_y + @height], @width, @height
	  end

	  # draw grids
	  render_x_grid
	  render_y_grid
	  
	  # draw axes
	  @pdf.stroke_color '000000'
	  @pdf.line_width 1
	  @pdf.line [org_x, org_y], [org_x+@width, org_y] if @xlegend[:legend_position] == 'bottom'
	  @pdf.line [org_x, org_y+@height], [org_x+@width, org_y+@height] if @xlegend[:legend_position] == 'top'
	  @pdf.line [org_x, org_y], [org_x, org_y+@height] if @ylegend[:legend_position] == 'left'
	  @pdf.line [org_x+@width, org_y], [org_x+@width, org_y+@height] if @ylegend[:legend_position] == 'right'
	  @pdf.stroke

	  # draw lines and dots
	  @data.each do |series|
		draw_lines series[:points], series[:line_spec]
		draw_dots series[:points], series[:point_spec]
	  end

	  render_xlegends
	  render_ylegends
	end

	def draw_lines points, line_spec
	  return if line_spec[:style] == 'no-line'
	  @line_spec = {style:'solid', width:1, color:'000000'}
	  @line_spec = line_spec if line_spec

	  org_x = @origin[0]
	  org_y = @origin[1]
	  xl_offset = @xlegend[:xleft_offset]
	  yb_offset = @ylegend[:bottom_offset]
	  @pdf.stroke_color = @line_spec[:color]
	  @pdf.line_width @line_spec[:width]
	  style = @line_spec[:style]
	  @pdf.line_width = @line_spec[:width]

	  case @line_spec[:style]
	  when 'dotted'
		@pdf.dash(1.5, :space => 1.5, :phase => 0)
	  when 'dashed'
		@pdf.dash(4, :space => 2, :phase => 0)
	  when 'long-dashed'
		@pdf.dash(6, :space => 3, :phase => 1)
	  end

	  start = points[0]
	  points.each do |p|
		next if start == p
		@pdf.line([start[0]+org_x+xl_offset, start[1]+org_y+yb_offset], [p[0]+org_x+xl_offset, p[1]+org_y+yb_offset])
		start = p
	  end
	  @pdf.stroke
	  @pdf.undash unless @line_spec[:style] == 'solid'
	end

	def draw_dots points, point_spec
	  org_x = @origin[0]
	  org_y = @origin[1]
	  @pdf.fill_color point_spec[:color]
	  xl_offset = @xlegend[:xleft_offset]
	  yb_offset = @ylegend[:bottom_offset]

	  points.each do |p|
		case point_spec[:shape]
		when 'circle'
			@pdf.fill_circle([p[0] + org_x + xl_offset, p[1] + org_y + yb_offset], point_spec[:size] /2)
		when 'square'
			d = point_spec[:size] /2
			@pdf.fill_rectangle([p[0] - d + org_x + xl_offset, p[1] + d + org_y + yb_offset], point_spec[:size], point_spec[:size])
		end
	  end
	  lc, mc, rc = '', '', ''
	  v_width, v_height = 0 , 0
	  if point_spec[:x_value] or point_spec[:y_value]
		minmax = find_min_max point_spec[:y_value]
		char_width = point_spec[:text_size] /2
		lc, mc, rc = '(', ', ', ')' if point_spec[:x_value] and point_spec[:y_value]
		v_width += point_spec[:x_width] if point_spec[:x_width]
		v_width += point_spec[:y_width] if point_spec[:y_width]
		v_width += 4 * char_width if point_spec[:y_width] and point_spec[:x_width]
		v_height += point_spec[:x_height] if point_spec[:x_height]
		v_height += point_spec[:y_height] if point_spec[:y_height] and point_spec[:x_height] == nil
		@pdf.fill_color point_spec[:text_color]
		points.each_with_index do |p, index|
		  next if v_width == 0 or v_height == 0  # safety measure
		  val = lc + point_spec[:x_value][index].to_s + mc + point_spec[:y_value][index].to_s + rc if lc != ''
		  val = point_spec[:y_value][index].to_s if lc == ''
		  y = org_y + yb_offset + p[1] + point_spec[:size]/2 + v_height + 2 # 2 units above the dot
		  y -= (6 + v_height + point_spec[:size]/2) if (point_spec[:y_value][index].to_f == 
		    minmax[0] and yb_offset+p[1]-point_spec[:size]/2 -v_height > 4) or y > (org_y+@height)

		  # code to decide alignment
		  align = :left				
		  x = org_x + xl_offset + p[0] - point_spec[:size]/2 
		  align = :center and x = org_x + xl_offset + p[0] - v_width/2 if (xl_offset + p[0]) >= v_width/2
		  align = :right and x = x = org_x + xl_offset + p[0] - v_width + point_spec[:size]/2 if (xl_offset + p[0] + v_width/2) >= @width
		  @pdf.text_box(val, 
					 :at => [x, y],
					 :width => v_width,
					 :height => v_height,
					 :size => point_spec[:text_size],
					 :align => align) 
		end
	  end
	  @pdf.stroke
	end

	def find_min_max points
	  min_y, max_y = Float::INFINITY, -Float::INFINITY
	  points.each do |p|
		min_y = p.to_f if p.to_f < min_y
		max_y = p.to_f if p.to_f > max_y
	  end
	  [min_y, max_y]
	end

	def render_xlegends
	  return unless @xlegend and @xlegend[:legends]
	  org_x = @origin[0]
	  org_y = @origin[1]
	  xlegends = @xlegend[:legends]
	  num = xlegends.size - 1
	  lw = @xlegend[:legend_width]
	  lh = @xlegend[:legend_height]
	  if @xlegend[:legend_position] == 'bottom'
		corner = :upper_right
		align = :right
	  else
		corner = :lower_left
		align = :left
	  end
	  angle = @xlegend[:angle]
	  @pdf.fill_color = @xlegend[:legend_color]
	  xl_offset = @xlegend[:xleft_offset]
	  xr_offset = @xlegend[:xright_offset]
	  y_offset = @xlegend[:y_offset]
	  xlegends.each_with_index do |legend, index|
		if @xlegend[:legend_position] == 'bottom'
		  y = org_y + y_offset
		  x = (index * (@width - xl_offset - xr_offset) / num).to_i + org_x - lw + xl_offset
		else
		  y = org_y + @height + y_offset + lh
		  x = (index * (@width - xl_offset - xr_offset) / num).to_i + org_x + xl_offset + lh*2/3
		end
		if angle == 0 or angle == nil
		  x += lw /2
		  align = :center
		end
		# pdf.stroke_rectangle [x, y], lw, lh # this is useful for debugging
		@pdf.text_box(legend, 
					 :at => [x, y],
					 :width => lw,
					 :height => lh,
					 :size => @xlegend[:text_size],
					 :align => align,
					 :rotate => angle,
					 :rotate_around => corner)
	  end

	  # process ticks
	  tick_length = @xlegend[:tick_length]
	  color = @xlegend[:tick_color] ? @xlegend[:tick_color] : '000000'
	  thick = @xlegend[:tick_width] ? @xlegend[:tick_width] : 1
	  @pdf.stroke_color color
	  @pdf.line_width thick
	  if @xlegend[:ticks] and @xlegend[:ticks].size > 1
		num = @xlegend[:ticks].size - 1
		@xlegend[:ticks].each_with_index do |t, index|
			next if t == 0
			x = (index * (@width - xl_offset - xr_offset) / num).to_i + org_x + xl_offset
			@pdf.line([x,org_y],[x, org_y - tick_length]) if @xlegend[:ticks_style] == 'out' and @xlegend[:legend_position] == 'bottom'
			@pdf.line([x,org_y+tick_length],[x, org_y]) if @xlegend[:ticks_style] == 'in' and @xlegend[:legend_position] == 'bottom'
			@pdf.line([x,org_y+@height],[x, org_y +@height+ tick_length]) if @xlegend[:ticks_style] == 'out' and @xlegend[:legend_position] == 'top'
			@pdf.line([x,org_y+@height],[x, org_y +@height-tick_length]) if @xlegend[:ticks_style] == 'in' and @xlegend[:legend_position] == 'top'
		end
	  end

	  render_x_header
	  @pdf.stroke
	end

	def render_x_header
	  return unless @xlegend[:header]
	  angle = @xlegend[:angle]
	  x =  @origin[0]
	  if @xlegend[:legend_position] == 'bottom'
	    y = @origin[1] - @xlegend[:h_height] - @xlegend[:legend_width] * Math.sin(angle* Math::PI / 180)
	  else
	    y = @origin[1] + @xlegend[:h_height] + @height + @xlegend[:legend_width] * Math.sin(angle* Math::PI / 180)
	  end
	  @pdf.text_box(@xlegend[:header], 
					 :at => [@origin[0], y],
					 :width => @width,
					 :height => @xlegend[:h_height],
					 :size => @xlegend[:h_text_size],
					 :style => @xlegend[:h_style],
					 :align => :center)		
	end

	def render_x_grid
	  return unless @xlegend and @xlegend[:grids] and @xlegend[:grids].size > 1
	  num = @xlegend[:grids].size - 1
	  xl_offset = @xlegend[:xleft_offset]
	  xr_offset = @xlegend[:xright_offset]
	  @pdf.line_width @xlegend[:g_width]
	  @pdf.stroke_color = @xlegend[:g_color]
	  @xlegend[:grids].each_with_index do |t, index|
		next if t == 0
		x = (index * (@width - xl_offset - xr_offset) / num).to_i + @origin[0] + xl_offset
		@pdf.line([x,@origin[1]],[x, @origin[1] + @height])
	  end
	  @pdf.stroke
	end

	def render_ylegends
	  return unless @ylegend and @ylegend[:legends]
	  org_x = @origin[0]
	  org_y = @origin[1]
	  ylegends = @ylegend[:legends]
	  num = ylegends.size - 1
	  lw = @ylegend[:legend_width]
	  lh = @ylegend[:legend_height]
	  if @ylegend[:legend_position] == 'left'
		corner = :upper_right
		align = :right
	  else
		corner = :upper_left
		align = :left
	  end
	  angle = @ylegend[:angle]
	  @pdf.fill_color = @ylegend[:legend_color]
	  top_offset = @ylegend[:top_offset]
	  bottom_offset = @ylegend[:bottom_offset]
	  x_offset = @ylegend[:x_offset]
	  ylegends.each_with_index do |legend, index|
	  	y = (index * (@height - top_offset - bottom_offset) / num).to_i + org_y + (lh/2).to_i + bottom_offset
	  	if @ylegend[:legend_position] == 'left'
		  x =  org_x - lw - x_offset		  
		else
		  x =  org_x + @width + x_offset
		end
		# @pdf.stroke_rectangle [x, y], lw, lh # this is useful for debugging
		@pdf.text_box(legend, 
					 :at => [x, y],
					 :width => lw,
					 :height => lh,
					 :size => @ylegend[:text_size],
					 :align => align,
					 :rotate => angle,
					 :rotate_around => corner)
	  end

	  # process ticks
	  tick_length = @ylegend[:tick_length]
	  color = @ylegend[:tick_color] ? @ylegend[:tick_color] : '000000'
	  thick = @ylegend[:tick_width] ? @ylegend[:tick_width] : 1
	  @pdf.stroke_color color
	  @pdf.line_width thick
	  if @ylegend[:ticks] and @ylegend[:ticks].size > 1
		num = @ylegend[:ticks].size - 1
		@ylegend[:ticks].each_with_index do |t, index|
		  next if t == 0
		  y = org_y + bottom_offset + (index * (@height - bottom_offset - top_offset) / num).to_i
		  @pdf.line([org_x - tick_length,y],[org_x, y]) if @ylegend[:ticks_style] == 'out' and @ylegend[:legend_position] == 'left'
		  @pdf.line([org_x,y],[org_x + tick_length, y]) if @ylegend[:ticks_style] == 'in' and @ylegend[:legend_position] == 'left'
		  @pdf.line([org_x+@width,y],[org_x+@width+tick_length, y]) if @ylegend[:ticks_style] == 'out' and @ylegend[:legend_position] == 'right'
		  @pdf.line([org_x+@width,y],[org_x+@width-tick_length, y]) if @ylegend[:ticks_style] == 'in' and @ylegend[:legend_position] == 'right'
		end
	  end

	  render_y_header
	  @pdf.stroke
	end

	def render_y_header
	  return unless @ylegend[:header] 
	  angle = @ylegend[:angle]
	  if @ylegend[:legend_position] == 'left'
	    x =  @origin[0] - @ylegend[:legend_width] * Math.cos(angle* Math::PI / 180) - @ylegend[:x_offset] - @ylegend[:h_height]
	  else
	    x =  @origin[0] + @width + @ylegend[:legend_width] * Math.cos(angle* Math::PI / 180) + @ylegend[:x_offset]
	  end
	  @pdf.text_box(@ylegend[:header], 
					 :at => [x, @origin[1]],
					 :width => @height,
					 :height => @ylegend[:h_height],
					 :size => @ylegend[:h_text_size],
					 :style => @ylegend[:h_style],
					 :align => :center,
					 :rotate => 90,
					 :rotate_around => :top_left)		
	end

	def render_y_grid
	  return unless @ylegend and @ylegend[:grids] and @ylegend[:grids].size > 1
	  num = @ylegend[:grids].size - 1
	  top_offset = @ylegend[:top_offset]
	  bottom_offset = @ylegend[:bottom_offset]
	  @pdf.line_width @ylegend[:g_width]
	  @pdf.stroke_color = @ylegend[:g_color]
	  @ylegend[:grids].each_with_index do |t, index|
		next if t == 0
		y = @origin[1] + bottom_offset + (index * (@height - bottom_offset - top_offset) / num).to_i
		@pdf.line([@origin[0],y],[@origin[0] +@width, y])
	  end
	  @pdf.stroke
	end

  end
end
