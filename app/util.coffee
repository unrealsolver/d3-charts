defaultGridFracture = 8

absFloor = (v) ->
  Math.sign(v) * Math.floor Math.abs v

generateGridConfig = (maxValue, maxFracture=defaultGridFracture) ->
  order = Math.floor Math.log10 maxValue
  orderMult = 10 ** order
  mantissa = maxValue / orderMult

  step = (2 ** absFloor Math.log2 mantissa / maxFracture) * orderMult
  size = step * Math.ceil maxValue / step

  {step, size}

generateGrid = (maxValue, maxFracture) ->
  config = generateGridConfig(maxValue, maxFracture)
  _.range 0, config.size + 1, config.step

module.exports = {generateGridConfig, generateGrid}

