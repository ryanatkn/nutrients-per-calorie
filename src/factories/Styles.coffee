module.exports = ->

  # Construct colors of the rainbow
  red = d3.rgb(255, 106, 97).toString()
  yellow = d3.rgb(255, 212, 113).toString()
  green = d3.rgb(148, 228, 109).toString()
  blue = d3.rgb(110, 210, 239).toString()
  violet = d3.rgb(208, 146, 244).toString()

  redYellow = d3.interpolateRgb(red, yellow)(0.5)
  yellowGreen = d3.interpolateRgb(yellow, green)(0.5)
  greenBlue = d3.interpolateRgb(green, blue)(0.5)
  blueViolet = d3.interpolateRgb(blue, violet)(0.5)
  violetRed = d3.interpolateRgb(violet, red)(0.5)

  rainbow = [
    green, greenBlue, blue, blueViolet, violet,
    violetRed, red, redYellow, yellow, yellowGreen
  ]

  comparisonRowHeight = 46

  Styles = {
    smallFontSize: 12
    smallFontLineHeight: 13
    largeFontSize: 24
    horizontalPadding: 6
    comparisonHeaderHeight: 92 # $comparison-header-height in main.scss
    comparisonRowHeight # $comparison-row-height in main.scss
    comparisonCellWidth: 20
    comparisonHorizontalSpacing: 44
    pieChartRadius: (comparisonRowHeight / 2) - 3
    colors: {
      red
      redYellow
      yellow
      yellowGreen
      green
      greenBlue
      blue
      blueViolet
      violet
      violetRed
      rainbow
      getRainbowColor: (i) ->      
        count = rainbow.length
        i -= count while i >= count
        rainbow[i]
      lightGray: "#bbb"
      blueText: d3.rgb(blue).darker(0.3) # for readability of small text
      greenText: d3.rgb(green).darker(0.3)
      redText: d3.rgb(red).darker(0.3)
    }
  }
