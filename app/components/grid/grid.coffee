require '../../helpers'
_ = require 'lodash'
template = '''
	<svg ng-attr-width='{{::vm.width+vm.mar.left+vm.mar.right}}' ng-attr-height='{{::vm.height + vm.mar.top +vm.mar.bottom}}' class='bottomChart' >
		<g class='main' shifter='[vm.mar.left, vm.mar.top]'>
			<rect class='background' ng-attr-width='{{vm.width}}' ng-attr-height='{{vm.height}}'/>
			<g class='g-dots'></g>
		</g>
	</svg>
'''

class Ctrl
	constructor: (@scope, @el, @window)->
		@width = 400
		@height=400
		@mar = 
			left: 20
			top: 10
			right: 15
			bottom: 30

		@Ver =d3.scale.linear().domain [0,50]
			.range [@height, 0]
		@Hor = d3.scale.linear().domain [0,50]
			.range [0,@width]

		@lines = []
		which = true
		@ODs = _.range 0, 3000
			.map =>
				d = [
						{ x: Math.random()*50,y: Math.random()*50},
						{x: Math.random()*50, y: Math.random()*50}
					]
				@lines.push	[d[0],
					(if which then {x:d[0].x,y:d[1].y} else {x:d[1].x,y:d[0].y} ),
					d[1]]
				which = !which
				d
		@lineFun = d3.svg.line()
			.x (d)=> @Hor d.x
			.y (d)=> @Ver d.y

link = (scope, el,attr,vm)->
	g= d3.select el[0]
		.select '.main'

	g.select '.g-dots'
		.selectAll 'lines'
		.data vm.lines
		.enter()
		.append 'path'
		.attr
			class: 'route'
			d: vm.lineFun

	# g.select '.g-dots'
	# 	.selectAll 'gDot'
	# 	.data vm.ODs
	# 	.enter()
	# 	.append 'g'
	# 	.classed 'g-OD',true
	# 	.selectAll 'gCirc'
	# 	.data (d)-> d
	# 	.enter()
	# 	.append 'circle'
	# 	.attr
	# 		r: .7
	# 		class: 'dot'
	# 		transform: (d)->
	# 			q = {x: vm.Hor(d.x), y: vm.Ver(d.y)}
	# 			"translate(#{q.x},#{q.y})"

der = ->
	directive = 
		controllerAs: 'vm'
		scope: {}
		template: template
		templateNamespace: 'svg'
		link: link
		controller: ['$scope','$element', '$window', Ctrl]

module.exports = der
