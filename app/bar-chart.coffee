module.exports = (el, data) ->
  svg = d3.select el

  data = [
    ["AD UNIT 01", 451]
    ["AD UNIT 02", 108]
    ["AD UNIT 03", 74]
  ]

  width = svg.attr 'width'
  height = svg.attr 'height'
  maxValue = _.last _.max data, (d) -> d[1]
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

  barWidth = 30
  barsGap = (chartDims.width - barWidth * data.length) / data.length + barWidth

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

  #svg
  #  .append('line')
  #    .attr('transform', "translate(#{chartDims.x}, #{chartDims.y})")
  #    .attr('x1', 0)
  #    .attr('y1', 0)
  #    .attr('x2', 0)
  #    .attr('y2', height)

  #svg
  #  .append('line')
  #    .attr('transform', "translate(#{width}, #{chartDims.y})")
  #    .attr('x1', 0)
  #    .attr('y1', 0)
  #    .attr('x2', 0)
  #    .attr('y2', height)

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

  bars = svg
    .append('g')
    .attr('transform', "translate(#{chartDims.x}, #{chartDims.y})")

  bars
    .selectAll()
    .data(data)
    .enter()
    .append('rect')
      .attr('x', (d, i) -> (i + 0.5) * barsGap - barWidth / 2)
      .attr('y', (d) -> chartDims.height - scale(d[1]))
      .attr('width', barWidth)
      .attr('height', (d) -> scale(d[1]))
      .style('fill', 'rgba(255, 255, 255, .80)')
      .style('stroke', 'none')

