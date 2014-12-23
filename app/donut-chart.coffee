module.exports = (el, data) ->
  svg = d3.select el
  
  baseDimension = _.min [+svg.attr('width'), +svg.attr('height')]

  config =
    radius: 0.5 * baseDimension
    innerRadius: 0.35 * baseDimension
    outerRadius: 0.5 * baseDimension
    baseFontSize: 0.32 * baseDimension
    descFontSize: 0.05 * baseDimension
    

  svg
    .style('font-family', 'Helvetica')

  defs =
    svg.append('defs')
    
  gradient = defs
    .append('radialGradient')
    .attr('id', 'gradient')
    .attr('gradientUnits', 'userSpaceOnUse')
    .attr('cx', 0)
    .attr('cy', 0)
    .attr('r', "#{config.radius/2.5}%")
    
  gradient
    .append('stop')
    .attr('offset', "#{config.radius/10}%")
    .style('stop-color', 'white')
  
  gradient
    .append('stop')
    .attr('offset', '70%')
    .style('stop-color', '#07B')

  arc = d3.svg.arc()
    .innerRadius(config.innerRadius)
    .outerRadius(config.outerRadius)
    .startAngle(0)
    .endAngle(Math.PI*2 * data.amount / 100)
    
  svg
    .append('path')
    .attr('d', arc)
    .attr('transform', "translate(#{config.radius},#{config.radius})")
    .style('fill', 'url(#gradient)')
  
  svg
    .append('text')
    .attr('text-anchor', 'middle')
    .attr('x', config.radius)
    .attr('y', config.radius * 1.25)
    .text(data.amount + '%')
    .style('font-size', "#{config.baseFontSize}px")
    .style('fill', '#18C')
  
  tspan = (sel, text) ->
    sel
      .append('tspan')
      .attr('dy', '1em')
      .attr('x', 0)
      .text(text)
    
  svg
    .append('text')
    .attr('transform', "translate(#{config.radius},#{config.radius*1.3})")
    .attr('text-anchor', 'middle')
    .call(tspan, 'Average video')
    .call(tspan, 'completion rate')
    .style('font-size', "#{config.descFontSize}px")
    .style('fill', '#555')

