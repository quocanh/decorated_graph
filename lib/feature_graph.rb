require 'prawn'
require_relative './decorated_graph'

pdf = Prawn::Document.new

points = [[4,2],[100,38], [150, 75], [270, 150]]
point_spec = {shape:'circle', size:6, color:'cc0000', y_value: [75, 950, 9300, 90000], y_width: 24, y_height: 7, text_size: 7, 
	text_color: '000000' , x_value: [4, 100, 150, 270], x_width: 14, x_height: 7
}
# point_spec = {shape:'circle', size:6, color:'cc0000'}
line_spec = {style:'solid', width:2, color:'00cc00'}
data = [{points: points, point_spec: point_spec, line_spec: line_spec}]

xlegends = ['Apr-11','May-11','Jun-11','Jul-11','Aug-11','Sep-11','Oct-11','Nov-11','Dec-12','Jan-12','Feb-12','Mar-12']
lw = 30
lh = 8
angle = 50
xl_offset = 0
xr_offset = 0
y_offset = -2
lcolor = "000000"
x_header = '12-month period' 
xlinput = {legends: xlegends, text_size:8, legend_width: lw, legend_height: lh, angle: angle, xleft_offset: xl_offset,
		   xright_offset: xr_offset, y_offset: y_offset, legend_color: lcolor, legend_position: 'bottom',
		   #header:x_header, h_style: :italic, h_height: 9, h_text_size: 9, 
		   ticks: [1,1], ticks_style: 'out', tick_length: 3
		   }

ylegends = ['100','1,000','10,000','100,000','1,000,000','10,000,000']
lw = 44
lh = 8
angle = 0
top_offset = 0
bottom_offset = 0
x_offset = 4
lcolor = "000000"
y_header = 'Sale Values in Some Currency'
style = :italic
ylinput = {legends: ylegends, text_size:8, legend_width: lw, legend_height: lh, angle: angle, top_offset: top_offset,
		   bottom_offset: bottom_offset, x_offset: x_offset, legend_color: lcolor, legend_position: 'left',
		   header:y_header, h_style: style, h_height: 9, h_text_size: 9, ticks: [1,1,1,1,1,1], ticks_style: 'out',
		   tick_length: 3, grids: [1,1,1,1,1,1], g_width: 0.5, g_color: '000000'}

origin2 = [80,440]
top = 15
right = 12
bottom = 35
left = 64
width = 280 + right + left
height = 160 + bottom + top
outer_color = 'e8ecec'
inner_color = 'ffffff'

graph = Prawn::DecoratedGraph.new(pdf, origin2, width, height, data, xlinput, ylinput, top, right, bottom, left, outer_color, inner_color) 
# graph = Prawn::DecoratedGraph.new(pdf, origin2, width, height, data) 
# graph = Prawn::DecoratedGraph.new(pdf, origin2, width, height, data, nil, nil, 1, 1, 0, 0, '000000') 
graph.draw_graph

# Additional tiems on the page
t= 'Production Sale Report.'
pdf.text t, {:size => 14, :color => '000088', :style => :bold}
pdf.move_down 20
t= 'This is a test graph for Production Sale Report'
pdf.text t, {:size => 10, :color => '000000', :style => :normal}
pdf.move_down 260

t = 'For informational purposes only. Solely to be used by the referenced recipient. Accuracy of all information subject to and qualified by primary data sources. Recipients should refer to primary data sources to verify.'
pdf.text t, {:size => 8, :color => '333333', :style => :italic}
t = 'Does not contain actual information. All information provided for informational purposes only solely to be used by the recipient. Form and content of actual reports delivered to recipients may differ from this document.'
pdf.text t, {:size => 8, :color => '333 333', :style => :italic}

pdf.table([["a","b","c"],["1","2","3"],["zz","ss","ff"]], :width => 450) do |table|
	table.rows(1..3).width = 150
end

p2 = [[5,120],[10,150], [50, 70], [270, 15]]
point_spec2 = {shape:'square', size:4, color:'cc0000'}
line_spec2 = {style:'long-dashed', width:1, color:'00cc00'}
# line_spec2 = {style:'no-line'}
data = [{points: points, point_spec: point_spec, line_spec: line_spec},{points: p2, point_spec: point_spec2, line_spec: line_spec2}]
angle = 50
y_offset = +2
x_header = '12-month period' 
xlinput = {legends: xlegends, text_size:8, legend_width: lw, legend_height: lh, angle: angle, xleft_offset: xl_offset,
		   xright_offset: xr_offset, y_offset: y_offset, legend_color: lcolor, legend_position: 'top',
		   header:x_header, h_style: :italic, h_height: 9, h_text_size: 9, 
		   ticks: [1,0,0,1,0,0,1,0,0,1,0,1], ticks_style: 'in', tick_length: 3
		   }
angle = -30
x_offset = 4
bottom_offset = 3
ylinput = {legends: ylegends, text_size:8, legend_width: lw, legend_height: lh, angle: angle, top_offset: top_offset,
		   bottom_offset: bottom_offset, x_offset: x_offset, legend_color: lcolor, legend_position: 'right',
		   header:y_header, h_style: style, h_height: 9, h_text_size: 9, ticks: [1,1,1,1,1,1], ticks_style: 'in',
		   tick_length: 3, grids: [0,1,1,1,1,1], g_width: 0.5, g_color: '000000'}

origin2 = [80,40]
top = 50
right = 64
bottom = 15
left = 12
width = 280 + right + left
height = 160 + bottom + top
outer_color = 'ffffee'
inner_color = 'ffffff'
graph = Prawn::DecoratedGraph.new(pdf, origin2, width, height, data, xlinput, ylinput, top, right, bottom, left, outer_color, inner_color) 
graph.draw_graph

pdf.render_file('../out/feature_graph.pdf')
