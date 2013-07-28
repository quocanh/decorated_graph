decorated_graph
===============

DecoratedGraph is a graph library that is built on top of ruby Prawn library to create graphs. 
It provides many features with flexibilities.

Each graph has these elements:
- Overall (outer) rectangle that contains everything that are related to the graph. Outer rectangle has its own background color.
- Reference point (origin) of a graph is its lower left conner of the outer rectangle, using absolute position coordinate 
    as defined in Prawn document.
- Inner area with actual graph (lines and dots) with background color. Position and size of inner area are defined by 
	outer rectangle's dimension and four relative distances to top, right, bottom, left edges.
- The actual graph consist of series of data sets, each set has dots with connecting lines.
- Each graph has ticks, grids and legends to x and y axes.
- Each dot in a data set has same shape, size and color
- Each line is a data set has same width, style and color
- Ticks and grids for each axis are independent for flexibility. Ticks can be drawn outward or inward. They have length and thickness.
- Girds also have thickness and style
- Legends can be rotated at specified angle. Legends can have a headline with syle and height to describes the meaning of values on the axis.
- Legends for x axis can be on top or at the bottom of actual graph.
- Legends for y axis can be at left or right of actual graph.

- You can put any number of grid lines (two or more is required). The position with 0 will not have grid line.
- You can put any number of ticks (two or more is required). The position with 0 will not have tick.
- You can display y-value or both x,y value for dots by providing y_value: (and x_value:) attribute.
   The code selects the best alignment for value
   y-values must be in numeric format, because the code tries to detect minimum value for vertical alignment
   The height for x/y-values should be the same as their text_size for best result
- Line style can be: solid, dotted, dashed, long-dashed
- Dot shape can be: circle, square
- You can display many lines in same graph by providing multiple data series
- You can display a dot series without connecting lines by using line_spec = {style:'no-line'}

Important notes: It's the programmer responsibility to provide all measurements, such as outer dimensions
legends width and height, points coordinates, ... so that everything will be rendered inside the outer rectangle

========> Sample inputs <=============
raw_graph pdf, origin2, width, height, data, xlegend, ylegend, top, right, bottom, left, color, inner_color
data = [{points: points1, point_spec: point_spec1, line_spec: line_spec1}, 
		{points: points2, point_spec: point_spec2, line_spec: line_spec2}, ...]
points1 = [[15,25],[100,38], [150, 75], [370, 150]]
point_spec1 = {shape:'circle', size:6, color:'cc0000', y_value: [750, 950, 9300, 90000], y_width: 24, y_height: 10, text_size: 8, 
	text_color: '000000' #, x_value: [15, 100, 150, 370], x_width: 14, x_height: 10
}
line_spec1 = {style:'solid', width:2, color:'00cc00'}
xlegends = ['Apr-11','May-11','Jun-11','Jul-11']
xlegend = {legends: xlegends, text_size:8, legend_width: 30, legend_height: 9, angle: 50, xleft_offset: 0,
		   xright_offset: 0, y_offset: 0, legend_color: '00ff00', legend_position: 'bottom',
		   #header:x_header, h_style: :italic, h_height: 12, h_text_size: 10, 
		   ticks: [1,1], ticks_style: 'out', tick_length: 3
		   }
ylegends = ['100','1,000','10,000','100,000','1,000,000','10,000,000']
ylinput = {legends: ylegends, text_size:8, legend_width: 44, legend_height: 10, angle: 0, top_offset: 0,
		   bottom_offset: 0, x_offset: 3, legend_color: 'ff0000', legend_position: 'left',
		   header:'Data Points', h_style: :italic, h_height: 12, h_text_size: 10, ticks: [1,1,1,1,1,1], ticks_style: 'out',
		   tick_length: 3, grids: [1,1,1,1,1,1], g_width: 0.5, g_color: '000000'}
========> End of sample inputs <=============
