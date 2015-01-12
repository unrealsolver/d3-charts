util = require './util'

module.exports = (el, data) ->
  svg = d3.select el

  width = svg.attr 'width'
  height = svg.attr 'height'

  maxValue = _.max([
    _.last _.max data, (d) -> d[1]
  ,
    _.last _.max data, (d) -> d[2]]
  )

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

  ticksData = util.generateGrid maxValue
  maxDomain = _.last ticksData

  scale = d3.scale.linear()
    .domain([0, maxDomain])
    .range([0, chartDims.height])

  clrWhite = 'rgba(255, 255, 255, .8)'

  svg
    .style('stroke-width', '1px')
    #.attr('shape-rendering', 'crispEdges')
    .style('stroke', clrWhite)
    .style('fill', 'none')
    .style('font-size', fontSize + 'px')
    .style('stroke-width', '.5')

  ## TICKS/GRID
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
        .style('fill', clrWhite)

  ticks
    .selectAll()
    .data(ticksData)
    .enter()
    .call(drawLine)
    .call(drawTick)

  ## LABELS
  labels = svg
    .append('g')
    .style('fill', clrWhite)

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
      .style('stroke-width', '2px')
      .style('fill', 'none')

  lines
    .append('path')
      .attr('d', line(2)(data))
      .style('stroke-width', '2px')
      .style('fill', 'none')
      .style('stroke-dasharray', '7, 7')

