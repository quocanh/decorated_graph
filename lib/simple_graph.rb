require 'prawn'
require_relative './decorated_graph'

pdf = Prawn::Document.new

pdf.text "This simple graph has no legends nor tick marks, because we only specify width, height, points' coordinates, and specifications for dots and lines",{:size => 10}

width = 280 
height = 160
origin = [80,530]
# Points coordinates are relative to the edge of the enclosing rectangle
points = [[4,2],[100,38], [150, 75], [270, 150]]
point_spec = {shape:'circle', size:6, color:'ff00ff'}
line_spec = {style:'solid', width:2, color:'00cc00'}
data = [{points: points, point_spec: point_spec, line_spec: line_spec}]

graph = Prawn::DecoratedGraph.new(pdf, origin, width, height, data) 
graph.draw_graph

pdf.move_down 200
pdf.text("This graph use the same data for points, with legends for x and y values along with tick-marks", {:size => 10});

xlegends = ['Apr-11','May-11','Jun-11','Jul-11','Aug-11']
lw = 30
lh = 8
lcolor = "000000"
x_header = '12-month period' 
xlinput = {legends: xlegends, text_size:8, legend_width: lw, legend_height: lh, legend_position: 'bottom',
		   ticks: [1,1,1], ticks_style: 'out', tick_length: 3
		   }

ylegends = ['100','1,000','10,000','100,000','1,000,000']
lw = 44
lh = 8
angle = 0
top_offset = 0
bottom_offset = 0
x_offset = 4
lcolor = "000000"
y_header = 'Sale Values in Some Currency'
style = :italic
ylinput = {legends: ylegends, text_size:8, legend_width: lw, legend_height: lh, legend_position: 'right', x_offset: 3,
		   header:y_header, h_style: style, h_height: 9, h_text_size: 9, ticks: [1,1,1,1,1], ticks_style: 'out',
		   tick_length: 3, grids: [1,1,1,1,1], g_width: 0.5, g_color: '000000'}
origin2 = [80,320]
graph = Prawn::DecoratedGraph.new(pdf, origin2, width, height, data, xlinput, ylinput) 
graph.draw_graph

pdf.move_down 200
pdf.text("You can see that for x-axis I provide 5 legends but only 3 tick-marks, which can be 'in' or 'out'", {:size => 10});
pdf.text("Legends can be placed 'top' or 'bottom' for x-axis and 'left' or 'right' for y-axis. ", {:size => 10});

pdf.render_file('../out/simple_graph.pdf')
