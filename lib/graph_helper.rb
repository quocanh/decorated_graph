module DecoratedGraph
  module Helper

  	# Scale array of points to fit within rectangle of 'width' and 'height'
  	# You can assign min and max value for each end_point of an axis
    # nil for a min or max value means "use min or max from the data set"
    # scale for each axis is specified separatedly: 'linear','loga' or 'date', default value is 'linear'
    def self.scale_data points, width, height, xmin, xmax, ymin, ymax, x_scale='linear', y_scale='linear'
      raise 'points must be array of pairs' unless points.kind_of? Array
	  raise 'xmax must be greater than xmin' unless !xmin or !xmax or xmax > xmin
	  raise 'ymax must be greater than ymin' unless !ymin or !ymax or ymax > ymin
	  raise 'width and height must be positive integers' unless width.kind_of? Integer and height.kind_of? Integer and width>0 and height>0
	  minmax = find_min_max(points, 'x', x_scale) if !xmin or !xmax
	  minx = xmin ? xmin : minmax[0] 
	  maxx = xmax ? xmax : minmax[1] 
	  minmax = find_min_max(points, 'y', y_scale) if !ymin or !ymax
	  miny = ymin ? ymin : minmax[0] 
	  maxy = ymax ? ymax : minmax[1] 
	  
	  d = maxx - minx
	  h = maxy - miny
	  out_points = []
      points.each do |p|
		raise 'Each point must be an array of two [numbers or date]' unless p.size == 2
	  	xval = get_value p[0], x_scale
	  	yval = get_value p[1], y_scale
	  	raise "Out of bound for x = #{xval}" unless xval >= minx and xval <= maxx
		raise "Out of bound for y = #{yval}" unless yval >= miny and yval <= maxy
		if x_scale == 'date'
		  x = scale_date_value xval, width, minx, maxx
		else
		  x = (1.0*(xval-minx)*width/d).round
		end
		if y_scale == 'date'
		  y = scale_date_value yval, height, miny, maxy
		else
		  y = (1.0*(yval-miny)*height/h).round
		end
		out_points << [x,y]
	  end
	  out_points
    end

    def self.get_value value, scale
      case scale
      when 'linear'
      	xval = value.to_f
      when 'loga'
      	xval = value.to_f
      	raise "Cannot get logarithm of non-positive value: #{xval}" if xval <= 0.0
      	xval = Math::log10(xval)
      when 'date'
      	xval = value
      end
      xval
    end

    def self.scale_date_value value, width, min_date, max_date
      max_m, max_y = max_date.strftime("%m").to_i, max_date.strftime("%Y").to_i
      min_m, min_y = min_date.strftime("%m").to_i, min_date.strftime("%Y").to_i
      month, year = value.strftime("%m").to_i, value.strftime("%Y").to_i
      count = max_y * 12 + max_m - min_y * 12 - min_m + 1 # number of months for whole range
      m = year * 12 + month - min_y * 12 - min_m # number of months for current date
      day = value.strftime("%d").to_i - 1
      day1 = value - day
      day2 = day1.next_month
      days_in_month = (day2 - day1).to_s.split("/")[0].to_i
      ((1.0 * width * m / count) + (1.0 * width * day) / (count * days_in_month)).to_i
    end

	def self.find_min_max points, x_or_y, scale
	  min_x, max_x = Float::INFINITY, -Float::INFINITY
	  min_x, max_x = Date.today + 36500, Date.today - 36500 if scale == 'date'
	  idx = (x_or_y == 'x') ? 0 : 1
	  points.each do |p|
	  	xval = p[idx] if scale == 'date'
	  	xval = p[idx].to_f if scale != 'date' 
	  	if scale == 'loga'
	  	  raise "Cannot get logarithm of non-positive #{x_or_y}-value: #{xval}" if xval <= 0.0
	  	  xval = Math::log10(xval)
	  	end
		min_x = xval if xval < min_x
		max_x = xval if xval > max_x
	  end
	  [min_x, max_x]
	end

	def self.format_date_legend min_date, max_date
	  min = min_date.strftime("%m")
	  max = max_date.strftime("%m")
	  raise "max_date must be later than min_date" unless max_date > min_date
	  out = [min_date.strftime("%b-%y")]
	  m = min_date.next_month
	  while m <= max_date
	  	out << m.strftime("%b-%y")
	  	m = m.next_month
	  end
	  out << ""
	  out
	end

  end # of Helper module
end # of DecoratedGraph module
