module.exports = (el, data) ->
  svg = d3.select(el)

  padding =
    top: 2
    left: 30
    right: 30
    bottom: 20
    
  config =
    width: svg.attr('width') - padding.left - padding.right
    height: svg.attr('height') - padding.top - padding.bottom
  
  ## Dots coordinates [[X, Y], ...]
  dots = []
  maxVal = (_.max data, (d) -> d[1])[1]
  heightMult = config.height / maxVal
  count = data.length
  xOffset = config.width / (count - 1)
  xDots = _.map data, (d, i) -> i * xOffset
  yDots = _.map data, (d) -> d[1] * heightMult
  dots = _.zip xDots, yDots
  fontSize = 10

  ## Defs
  defs = svg.append('defs')

  ## Gradient
  gradient = defs
    .append('linearGradient')
    .attr('id', 'video-area-gradient')
    .attr('x1', '0%')
    .attr('y1', '0%')
    .attr('x2', '0%')
    .attr('y2', '100%')

  gradient
    .append('stop')
    .attr('offset', '0%')
    .style('stop-color', '#67C1DB')

  gradient
    .append('stop')
    .attr('offset', '45%')
    .style('stop-color', '#8FD5E6')
  
  gradient
    .append('stop')
    .attr('offset', '95%')
    .style('stop-color', '#FFF')
  
  ## ClipPath
  clipPath = defs
    .append('clipPath')
    .attr('id', 'video-area-clip-path')
    
  clipPathPoly = d3.svg.line()
    .x((d) -> d[0])
    .y((d) -> config.height - d[1])
    .interpolate('linear')
    
  clipPath
    .append('path')
      .attr('d', clipPathPoly(dots.concat([[config.width, 0], [0, 0]])))

  svg
    .style('font-size', fontSize + 'px')

  # Chart
  chart = svg
    .append('g')
    .attr('transform', "translate(#{padding.left}, #{padding.top})")
  
  chart
    .append('rect')
      .attr('x', 0)
      .attr('y', 0)
      .attr('width', config.width)
      .attr('height', config.height)
      .attr('clip-path', 'url(#video-area-clip-path)')
      .style('fill', 'url(#video-area-gradient)')
  
  grid = chart
    .append('g')
      .style('fill', 'none')
      .style('stroke-width', '1px')
      .style('stroke', '#5AB7D5')
      .style('stroke-dasharray', '3, 3')
      .style('shape-rendering', 'crispedges')

  grid
    .selectAll('line')
    .data(dots)
    .enter()
      .append('line')
      .attr('x1', (d) -> d[0])
      .attr('y1', (d) -> config.height - d[1])
      .attr('x2', (d) -> d[0])
      .attr('y2', config.height)
      
  line = d3.svg.line()
    .x((d) -> d[0])
    .y((d) -> config.height - d[1])
    .interpolate('linear')

  chart
    .append('g')
    .append('path')
      .attr('d', line(dots))
        .style('stroke-width', '2.5px')
        .style('stroke', '#0085B7')
        .style('fill', 'none')
        
  chart
    .append('g')
    .style('font-family', 'Helvetica')
    .selectAll('text')
    .data(_.zip _.map(data, (d) -> d[0]), _.map(dots, (d) -> d[0]))
    .enter()
    .append('text')
    .attr('x', (d) -> d[1] - 30)
    .attr('y', config.height + padding.bottom)
    .text((d) -> d[0])
    .style('fill', '#0085B7')

