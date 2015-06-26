require '../../helpers'
_ = require 'lodash'
template = '''
	<svg ng-attr-width='{{::vm.width+vm.mar.left+vm.mar.right}}' ng-attr-height='{{::vm.height + vm.mar.top +vm.mar.bottom}}' class='bottomChart' >
		<g class='main' shifter='[vm.mar.left, vm.mar.top]'>
			<circle class='background' ng-attr-r='{{vm.height/2}}' shifter='[vm.width/2, vm.height/2]'/>
			<g class='g-dots' shifter='[vm.width/2,-vm.height/2]'></g>
		</g>
	</svg>
'''

class Ctrl
	constructor: (@scope, @el, @window)->
		@width = 500
		@height=500
		@mar = 
			left: 20
			top: 10
			right: 15
			bottom: 30

		V =d3.scale.linear().domain [0,50]
			.range [@height, 0]
		H = d3.scale.linear().domain [0,50]
			.range [0,@width]
		samp = ->
			t = 2*Math.PI*Math.random()
			u = Math.random() + Math.random()
			r = if u >1 then 2-u else u
			res = 
				theta: t
				r: r * 25
			# [r*Math.cos(t), r*Math.sin(t)]

		@lines = []
		_.range 0, 2000
			.forEach =>

				a = samp()
					# theta: Math.random()*2*Math.PI,
					# r: Math.random()*25

				b = samp()
					# theta: Math.random()*2*Math.PI, 
					# r: Math.random()*25

				if Math.abs(a.theta - b.theta) < 2
					if a.r <= b.r
						which = +((a.theta - b.theta) > 0)
						res = "M #{H(a.r*Math.cos(a.theta))} #{V(a.r*Math.sin(a.theta))} A #{H(a.r)} , #{H(a.r)} 0  0,#{which} #{H(a.r*Math.cos(b.theta))} #{V(a.r*Math.sin(b.theta))} L #{H(b.r*Math.cos(b.theta))} #{V(b.r*Math.sin(b.theta))}"
						@lines.push res
					else
						which = +((a.theta - b.theta ) < 0)
						res = "M #{H(b.r*Math.cos(b.theta))}  #{V(b.r*Math.sin(b.theta))} A #{H(b.r)} , #{H(b.r)} 0  0,#{which} #{H(b.r*Math.cos(a.theta))} #{V(b.r*Math.sin(a.theta))} L #{H(a.r*Math.cos(a.theta))} #{V(a.r*Math.sin(a.theta))}"
						@lines.push res
				else
					res = "M #{H(a.r*Math.cos(a.theta))}  #{V(a.r*Math.sin(a.theta))} L #{H(0)} #{V(0)} L #{H(b.r*Math.cos(b.theta))}  #{V(b.r*Math.sin(b.theta))}"
					@lines.push res

link = (scope, el,attr,vm)->
	g= d3.select el[0]
		.select '.main'

	lines = g.select '.g-dots'
		.selectAll 'lines'
		.data vm.lines.map (d)->
			res = 
				line: d
				l: 0
		.enter()
		.append 'path'
		.attr
			class: 'route'
			d: (d)->d.line
	lines.attr 'stroke-dasharray', (d)->
			l = d3.select this
				.node()
				.getTotalLength()
			"#{l},#{l}"
		.attr 'stroke-dashoffset': (d)->
			l = d3.select this
				.node()
				.getTotalLength()
			l
	setTimeout ()=>
		lines.transition()
			.ease 'cubic'
			.duration 1200
			.delay (d,i)->
				i*5
			.attr 'stroke-dashoffset', 0
		, 1000


der = ->
	directive = 
		controllerAs: 'vm'
		scope: {}
		template: template
		templateNamespace: 'svg'
		link: link
		controller: ['$scope','$element', '$window', Ctrl]

module.exports = der
