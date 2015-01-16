## Features:
## * Long text lines truncating
## * Automatic color scale
## * ES3 compatible
## Deps:
## * underscore / lodash

module.exports = (el, data) ->
  svg = d3.select el

  ## Sample data
  #data =
  #  labels: ['K_Segment', 'K_Other_One', 'K_One_More', 'K_Segment', 'K_Other_One', 'K_One_More']
  #  data: [
  #    [100, 94, 84, 66, 64, 44]
  #    [91, 100, 70, 56, 54, 54]
  #    [93, 82, 100, 46, 54, 34]
  #    [76, 84, 84, 100, 44, 54]
  #    [61, 65, 60, 66, 100, 34]
  #    [63, 52, 56, 56, 74, 100]
  #  ]
  
  ## R/O config
  conf =
    cell:
      width: 48
      height: 18
      fontSize: 10
    grid:
      gap: 5
      fontSize: 8
    labelTrimLength: 150
    color: '#EC4169'
  
  ## PRE-RENDERING ##
  
  ## Mutable state + internal config
  state =
    dim:
      x: _.size _.max data.data, (d) -> _.size d
      y: _.size data.data
    gridOffset:
      x: conf.cell.width + conf.grid.gap
      y: conf.cell.height + conf.grid.gap
    heatmapOffset:
      x: conf.labelTrimLength
      y: 50
    maxLabelLength: 0
    labels: []
  
  
  #svg
  #  .style('shape-rendering', 'crispedges')
    
  chart = svg.append('g')
    .attr('transform', 'translate(50, 50)')
  
  
  ## FUNCTIONS ##
  
  gridLineStep = (axis, d, i) ->
    Math.floor(i * state.gridOffset[axis] + state.heatmapOffset[axis] - conf.grid.gap/2)
  
  gridLineLength = (axis) ->
    state.heatmapOffset[axis] + state.gridOffset[axis] * state.dim[axis]

  adjustLabelLength = (s) ->
    s.each (d) ->
      len = d.length
      while @.getBBox().width > conf.labelTrimLength
        @textContent = d.slice(0, len--) + '… '
      ## Caching
      state.labels.push @textContent
        
  drawLabelsMixin = (s, innerCall) ->
    s.selectAll('text')
    .data(data.labels)
    .enter()
    .append('text')
      .text((d) -> d)
      .call(innerCall)
  
  calculateMaxYLabelWidth = (s) ->
    s.each ->
      len = @.getBBox().width
      if len > state.maxLabelLength
        if len > conf.labelTrimLength
          len = conf.labelTrimLength
        state.maxLabelLength = len + 20
  
  yTextMixin = (s) ->
    s.attr('y', (d, i) -> gridLineStep('y', d, i) + (conf.grid.fontSize + state.gridOffset.y)/2)
      .call(calculateMaxYLabelWidth)
      .call(adjustLabelLength)
  
  xTextMixin = (s) ->
    s.attr('y', 35)
      .attr('transform', (d, i) -> "translate(#{gridLineStep('x', d, i)}, 12) rotate(-45)")
  
  ## LABELS
  
  labels = chart
    .append('g')
      .style('font-size', conf.grid.fontSize + 'px')
      .style('fill', '#888')
  
  yLabels = labels
    .append('g')
    .attr('class', 'y-text')
    .call(drawLabelsMixin, yTextMixin)

  xLabels = labels
    .append('g')
  
  xLabels
    .attr('class', 'x-text')
    .call(drawLabelsMixin, xTextMixin)

  ## GRID
  
  grid = chart.append('g')
    .attr('class', 'grid')
      .style('stroke-width', .5)
      .style('stroke', '#CECED0')
      .style('stroke-dasharray', '2, 2')
      .style('fill', 'none')

  grid
    .append('g')
    .attr('class', 'horizontal-grid')
      .selectAll('line')
      .data(new Array state.dim.y+1)
      .enter()
      .append('line')
        .attr('x1',0)
        .attr('y1', _.bind(gridLineStep, 0, 'y'))
        .attr('x2', gridLineLength 'x')
        .attr('y2', _.bind(gridLineStep, 0, 'y'))
        .style('stroke-dasharray', (d, i) -> i == 0 && '0')
  
  grid
    .append('g')
    .attr('class', 'vertical-grid')
      .selectAll('line')
      .data(new Array state.dim.x+1)
      .enter()
      .append('line')
        .attr('x1', _.bind(gridLineStep, 0, 'x'))
        .attr('y1', 35)
        .attr('x2', _.bind(gridLineStep, 0, 'x'))
        .attr('y2', gridLineLength 'y')
        .style('stroke-dasharray', (d, i) -> i == 0 && '0')

  ## HEATMAP

  heatmap = chart.append('g')
    .attr('class', 'heatmap')
    .attr('transform', "translate(#{state.heatmapOffset.x}, #{state.heatmapOffset.y})")
  
  tr = heatmap
    .selectAll('g.tr')
    .data(data.data)
    .enter()
    .append('g')
      .attr('transform', (d, i) -> "translate(0, #{i*state.gridOffset.y})")
      .attr('class', 'tr')
      
  td = tr
    .selectAll('g.td')
    .data((d) -> d)
    .enter()
    .append('g')
      .attr('class', 'td')
      .attr('transform', (d, i) -> "translate(#{i*state.gridOffset.x}, 0)")

  rectFillMixin = (s) ->
    s
      .style('opacity', (d) -> d < 100 && Math.floor(d/10)/10)
      .style('fill', (d) -> d < 100 && conf.color || '#EBECEC')

  td
    .append('rect')
      .call(rectFillMixin)
      .attr('width', conf.cell.width)
      .attr('height', conf.cell.height)

  ## TEXT

  td
    .append('text')
      .attr('y', (conf.cell.height + conf.cell.fontSize) / 2)
      .attr('x', conf.cell.width / 2)
      .style('text-anchor', 'middle')
      .style('font-size', conf.cell.fontSize  + 'px')
      .style('fill', '#64666B')
      .text((d) -> d)
