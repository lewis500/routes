require '../../helpers'
_ = require 'lodash'
template = '''
	<svg ng-attr-width='{{::vm.width+vm.mar.left+vm.mar.right}}' ng-attr-height='{{::vm.height + vm.mar.top +vm.mar.bottom}}'  >
		<g class='main' shifter='[vm.mar.left, vm.mar.top]'>
			<rect class='background' ng-attr-width='{{::vm.width}}' ng-attr-height='{{::vm.height}}'/>
			<g class='g-dots'></g>
		</g>
	</svg>
	<svg width='75' ng-attr-height='{{::vm.height + vm.mar.top +vm.mar.bottom}}' >
		<g class='main' shifter='[vm.mar.left, vm.mar.top]'>
			<rect class='avg' width='75' ng-attr-y='{{vm.height - vm.average}}' ng-attr-height='{{vm.average }}'/>
		</g>
	</svg>
'''

class Ctrl
	constructor: (@scope, @el, @window,@element)->
		@width = 500
		@height=500
		@mar = 
			left: 5
			top: 10
			right: 5
			bottom: 30

		@Ver =d3.scale.linear().domain [0,50]
			.range [@height, 0]
		@Hor = d3.scale.linear().domain [0,50]
			.range [0,@width]

		@lines = []
		which = true
		_.range( 0, 2000)
			.forEach (i)=>
				d = [
						{ x: Math.random()*50,y: Math.random()*50},
						{x: Math.random()*50, y: Math.random()*50}
					]
				# l = Math.abs(d[0].x - d[1].x) + Math.abs(d[0].y - d[1].y)
				# lengths.push l
				@lines.push	[
						d[0],
						(if which then {x:d[0].x,y:d[1].y} else {x:d[1].x,y:d[0].y} ),
						d[1]
					]
				which = !which


		@lineFun = d3.svg.line()
			.x (d)=> @Hor d.x
			.y (d)=> @Ver d.y

		g = d3.select @element[0]
			.select '.main'

		lines = g.select '.g-dots'
			.selectAll 'lines'
			.data @lines
			.enter()
			.append 'path'
			.attr
				class: 'route'
				d: @lineFun
		lengths = []

		lines.attr 'stroke-dasharray', (d)->
				l = d3.select this
					.node()
					.getTotalLength()
				lengths.push l
				"#{l},#{l}"
			.attr 'stroke-dashoffset': (d)->
				l = d3.select this
					.node()
					.getTotalLength()
				l

		avg = 0
		averages = lengths.map (l,i)->
			avg = (avg * i + l)/(i+1)

		@average = 0

		lines.transition 'hello'
			.ease 'cubic'
			.duration 500
			.delay (d,i)->
				i*5
			.attr 'stroke-dashoffset', 0
			.transition ''
			.each 'end', (d,i)=>
				@average = averages[i]
				@scope.$evalAsync()

der = ->
	directive = 
		controllerAs: 'vm'
		scope: {}
		template: template
		templateNamespace: 'svg'
		controller: ['$scope','$element', '$window', '$element', Ctrl]

module.exports = der
