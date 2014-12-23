module.exports = (el, data) ->
  svg = d3.select el

  data = [
    # Segment # imps # ctr # population #
    ['Segment', 5234,  23, 14235]
    ['Segment', 2234,  8,  235]
    ['Segment', 8234,  13, 54235]
    ['Segment', 2634,  7,  235]
    ['Segment', 2034,  8.5,34235]
    ['Segment', 2834,  9,  4235]
  ]

  maxImps        = (_.max data, (d) -> d[1])[1]
  maxCtr         = (_.max data, (d) -> d[2])[2]
  maxPopulation  = (_.max data, (d) -> d[3])[3]

  getDomainStep = (value) ->
    exponent = Math.floor Math.log10 value
    expMult = Math.pow 10, exponent

  enlargeDomain = (value) ->
    expMult = getDomainStep value
    Math.ceil(value / expMult) * expMult

  xDomainStep = getDomainStep maxImps
  yDomainStep = getDomainStep maxCtr
  xMaxDomain  = enlargeDomain maxImps
  yMaxDomain  = enlargeDomain maxCtr

  width = svg.attr 'width'
  height = svg.attr 'height'

  fontSize = 12
  maxBubbleSize = 40
  gridDensity = 8

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

  xScale = d3.scale.linear()
    .domain([0, xMaxDomain])
    .range([0, chartDims.width])

  yScale = d3.scale.linear()
    .domain([0, yMaxDomain])
    .range([0, chartDims.height])

  sizeScale = d3.scale.log()
    .domain([1, maxPopulation])
    .range([0, maxBubbleSize])

  ## SVG
  svg
    .style('stroke-width', '1px')
    .attr('shape-rendering', 'crispEdges')
    .style('font-family', 'Open Sans')
    .style('stroke', '#59F')
    .style('fill', '#59F')
    .style('font-size', fontSize + 'px')

  chart = svg
    .append('g')
      .attr('transform', 'translate(30, 0)')

  ## GRID
  grid = chart
    .append('g')
      .style('stroke', '#DDD')

  ## HORIZONTAL GRID
  getGridDivision = (step, max, density) ->
    Math.ceil(Math.log(step * density / max) / Math.LN2)

  #yDomainStep = yDomainStep / getGridDivision(yDomainStep, yMaxDomain, gridDensity)
  horGridData = d3.range(0, yMaxDomain + 1, yDomainStep)

  horGrid = grid
    .append('g')

  horGrid
    .selectAll()
    .data(horGridData)
    .enter()
    .append('line')
      .attr('x1', 0)
      .attr('y1', (d) -> chartDims.height - yScale d)
      .attr('x2', chartDims.width)
      .attr('y2', (d) -> chartDims.height - yScale d)

  ## VERT GRID
  #xDomainStep = xDomainStep / getGridDivision(xDomainStep, xMaxDomain, gridDensity)
  vertGridData = d3.range(0, xMaxDomain + 1, xDomainStep)

  horGrid = grid
    .append('g')

  horGrid
    .selectAll()
    .data(vertGridData)
    .enter()
    .append('line')
      .attr('x1', (d) -> xScale d)
      .attr('y1', 0)
      .attr('x2', (d) -> xScale d)
      .attr('y2', chartDims.height)

  ## BUBBLES
  bubbles = chart
    .append('g')
      .attr('shape-rendering', 'geometricPrecision')
      .style('fill', 'rgba(70, 160, 255, .6)')
      .style('stroke-width', 1)
      .style('stroke', 'rgba(255, 255, 255, .6)')

  bubbles
    .selectAll()
    .data(data)
    .enter()
    .append('circle')
      .attr('cx', (d) -> xScale d[1])
      .attr('cy', (d) -> yScale d[2])
      .attr('r', (d) -> sizeScale d[3])

  ## AXISES
  drawAxis = (sel, label, length) ->
    cl = centerLine = fontSize / 3
    l = length
    labelWidth = sel
      .append('text')
        .attr('x', 0)
        .attr('y', centerLine + fontSize / 2)
        .attr('stroke', 'none')
        .text(label)[0][0]
          .getBBox()
          .width
    sel
      .append('line')
        .attr('x1', labelWidth + 10)
        .attr('y1', centerLine)
        .attr('x2', length)
        .attr('y2', centerLine)
    sel
      .append('polygon')
        .attr('points', "#{l},0 #{l+cl*2.6},#{cl} #{l},#{cl*2}")
        .style('stroke', 'none')

  axises = svg
    .append('g')
      .style('stroke', '#07B')
      .style('stroke-width', 1)
      .style('fill', '#07B')
      #.attr('font-size', fontS)

  ## HORIZONTAL AXIS
  horAxis = axises
    .append('g')
      .attr('transform', "translate(30, #{height - 20})")
      .call(drawAxis, 'IMPRESSIONS', chartDims.width)

  ## VERTICAL AXIS
  vertAxis = axises
    .append('g')
      .attr('transform', "rotate(-90, 0, #{height-20}) translate(20, #{height - 20})")
      .call(drawAxis, 'CTR', chartDims.width)

