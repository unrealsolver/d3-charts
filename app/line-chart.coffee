util = require './util'

module.exports = (el, data) ->
  svg = d3.select el

  width = svg.attr 'width'
  height = svg.attr 'height'

  data = [
    ['09/16/14', 102, 110]
    ['09/17/14', 110, 130]
    ['09/18/14', 112, 159]
    ['09/19/14', 126, 102]
    ['09/20/14', 114, 91]
    ['09/21/14', 105, 127]
  ]

  maxValue = _.max([
    _.last _.max data, (d) -> d[1]
  ,
    _.last _.max data, (d) -> d[2]]
  )

  exponent = Math.floor Math.log10 maxValue
  expMult = Math.pow 10, exponent
  maxDomain = Math.ceil(maxValue / expMult) * expMult
  maxTicks = 4

  fontSize = 9

  conf =
    offset:
      left: 60
      right: 0
      top: fontSize
      bottom: 20

  chartDims =
    x: conf.offset.left
    y: conf.offset.top
    width: width - conf.offset.left - conf.offset.right
    height: height - conf.offset.top - conf.offset.bottom

  barWidth = 50
  barsGap = chartDims.width / data.length

  scale = d3.scale.linear()
    .domain([0, maxDomain])
    .range([0, chartDims.height])

  clrWhite = 'rgba(255, 255, 255, .8)'

  svg
    .style('stroke-width', '1px')
    .attr('shape-rendering', 'crispEdges')
    .style('font-family', 'Open Sans')
    .style('stroke', clrWhite)
    .style('fill', clrWhite)
    .style('font-size', fontSize + 'px')

  ## TICKS / GRID
  tickStep = expMult
  while maxDomain / tickStep < maxTicks
    tickStep /= 2

  ticksData = d3.range(0, maxDomain + 1, tickStep)
  ticksData = util.generateGrid maxValue

  ticks = svg
    .append('g')
      .attr('transform', "translate(0, #{chartDims.y})")

  drawLine = (sel) ->
    sel
      .append('line')
        .attr('x1', conf.offset.left)
        .attr('y1', (d) -> chartDims.height - scale(d))
        .attr('x2', width)
        .attr('y2', (d) -> chartDims.height - scale(d))
        .style('stroke-dasharray', (d) -> d > 0 && '2, 2')

  drawTick = (sel) ->
    sel
      .append('text')
        .attr('x', conf.offset.left - 10)
        .attr('y', (d) -> chartDims.height - scale(d) + fontSize / 2)
        .text((d) -> d + (d > 0 && 'K' || ''))
        .style('stroke', 'none')
        .style('text-anchor', 'end')

  ticks
    .selectAll()
    .data(ticksData)
    .enter()
    .call(drawLine)
    .call(drawTick)

  ## LABELS
  labels = svg
    .append('g')

  labels
    .selectAll()
    .data(data)
    .enter()
    .append('text')
      .attr('x', (d, i) -> (i + 0.5) * barsGap + conf.offset.left)
      .attr('y', height)
      .text((d) -> d[0])
      .style('stroke', 'none')
      .style('text-anchor', 'middle')

  ## CHART LINES
  line = (dataIndex) ->
    d3.svg.line()
      .x((d, i) -> (i + 0.5) * barsGap)
      .y((d) -> chartDims.height - scale(d[dataIndex]))
      .interpolate('linear')

  lines = svg
    .append('g')
      .attr('transform', "translate(#{chartDims.x}, #{chartDims.y})")
      .attr('shape-rendering', 'auto')

  lines
    .append('path')
      .attr('d', line(1)(data))
      .style('stroke-width', '3px')
      .style('fill', 'none')

  lines
    .append('path')
      .attr('d', line(2)(data))
      .style('stroke-width', '3px')
      .style('fill', 'none')
      .style('stroke-dasharray', '7, 7')

