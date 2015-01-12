module.exports = (el, data) ->
  svg = d3.select el

  svg
    .style('stroke', 'white')
    .style('opacity', .8)
    .style('stroke-width', '.5')
    
  height = svg.attr('height')
  width = svg.attr('width')
  bottomOffset = height*0.12
  radius = width/2
  
  config =
    uniquesRadius: radius
    requestsRadius: radius * data.requests / data.uniques
    bottomLine: height - bottomOffset
    ellipseAspect: 0.7
    stoplinesMargin: 10

  stopLinesData = [1, config.requestsRadius * 2, config.uniquesRadius * 2]

  defs = svg
    .append('defs')

  clipPath = defs
    .append('clipPath')
      .attr('id', 'clip-path')

  clipPathInst = clipPath
    .append('rect')
      .attr('x', 0)
      .attr('y', 0)
      .attr('width', width)
      .attr('height', config.bottomLine)
  
  dashed = svg
    .append('g')
    .style('fill', 'none')
    .style('stroke-dasharray', '3, 1')

  ellipses = dashed
    .append('g')
    .attr('clip-path', 'url(#clip-path)')

  ellipses
    .append('ellipse')
    .attr('rx', config.uniquesRadius)
    .attr('ry', config.uniquesRadius * config.ellipseAspect)
    .attr('cy', config.bottomLine)
    .attr('cx', config.uniquesRadius)

  ellipses
    .append('ellipse')
    .attr('rx', config.requestsRadius)
    .attr('ry', config.requestsRadius * config.ellipseAspect)
    .attr('cy', config.bottomLine)
    .attr('cx', config.requestsRadius)
    .style('fill', 'rgba(0, 0, 0, .1)')

  stopLines = dashed
    .append('g')

  stopLines
    .selectAll('line')
    .data(stopLinesData)
    .enter()
    .append('line')
      .attr('x1', (d) -> d)
      .attr('y1', config.bottomLine + config.stoplinesMargin)
      .attr('x2', (d) -> d)
      .attr('y2', height)
      #.style('shape-rendering', 'crispedges')
      .style('stroke', 'rgba(255, 255, 255, .5)')

  textLabels = svg
    .append('g')

  textLabelsData = _.zip(
    stopLinesData.slice(1),
    [data.requests, data.uniques],
    ['UNIQUES', 'REQUESTS']
  )

  tspan = (sel, text, size) ->
    sel
      .append('tspan')
      .attr('dy', '1em')
      .attr('x', 0)
      .style('font-size', size)
      .text(text)

  textLabels
    .selectAll()
    .data(textLabelsData)
    .enter()
    .append('text')
      .attr('transform', (d) -> "translate(#{d[0] - 8}, #{config.bottomLine + config.stoplinesMargin + 7})")
      .attr('x', 0)
      .attr('y', 0)
      .call(tspan, (d) -> d[1] + 'K')
      .call(tspan, ((d) -> d[2]), '10px')
      .style('stroke', 'none')
      .style('fill', 'white')
      .attr('text-anchor', 'end')
      .style('font-size', '12px')

