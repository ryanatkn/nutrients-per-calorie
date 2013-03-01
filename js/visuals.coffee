visuals = angular.module("visuals", [])


# Provides styling variables
visuals.factory "Styles", ->
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

  comparisonRowHeight = 46

  Styles = {
    smallFontSize: 12
    smallFontLineHeight: 13
    largeFontSize: 28
    horizontalPadding: 6
    comparisonHeaderHeight: 140 # $comparison-header-height in main.scss
    comparisonRowHeight # $comparison-row-height in main.scss
    comparisonCellWidth: 20
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
      rainbow: [
        green, greenBlue, blue, blueViolet, violet,
        violetRed, red, redYellow, yellow, yellowGreen
      ]
      lightGray: "#bbb"
      blueText: d3.rgb(blue).darker(0.3) # for readability of small text
      greenText: d3.rgb(green).darker(0.3)
      redText: d3.rgb(red).darker(0.3)
    }
  }


# Draws a pie chart from `data` on the `vis` with the given `radius`.
# Returns the d3 visualization.
drawPieChart = (vis, data, radius, options = {}) ->
  {radius, x, y} = options
  x ?= radius
  y ?= radius

  vis.append("g")
    .data([data])
    .attr("transform", "translate(#{x}, #{y})")

  arc = d3.svg.arc()
    .outerRadius(radius)

  pie = d3.layout.pie()
    .value((d) -> d.value)
    .sort((d) -> data.indexOf(d))

  arcs = vis.selectAll("g.slice")
    .data(pie)
    .enter()
      .append("g")
        .attr("class", "slice")

  arcs.append("path")
    .attr("fill", (d, i) -> d.data.color)
    .attr("d", arc)

  vis


# Displays in a pie chart the % calorie contributions of protein, fat, carbs, and alcohol for a `food`.
visuals.directive "foodPieChart", (Styles) ->
  restrict: "E"
  scope:
    food: "="
  link: (scope, element, attrs) ->

    vis = d3.select(element[0])
      .append("svg")
        .attr("width", Styles.pieChartRadius * 2)
        .attr("height", Styles.pieChartRadius * 2)

    data = [
      value: scope.food["Total lipid (fat)"]
      color: Styles.colors.red
    ,
      value: scope.food["Protein"]
      color: Styles.colors.blue
    ,
      value: scope.food["Carbohydrate, by difference"]
      color: Styles.colors.green
    ,
      value: scope.food["Alcohol, ethyl"]
      color: Styles.colors.lightGray
    ]

    drawPieChart vis, data, Styles.pieChartRadius


# Displays a labeled pie chart to explain how to interpret them.
visuals.directive "foodPieChartLegend", (Styles) ->
  restrict: "E"
  scope: {}
  link: (scope, element, attrs) ->
    
    data = [
      value: 0.3333
      color: Styles.colors.red
    ,
      value: 0.3333
      color: Styles.colors.blue
    ,
      value: 0.3333
      color: Styles.colors.green
    ]

    xOffset = 50
    
    vis = d3.select(element[0])
      .append("svg")
        .attr("width", Styles.pieChartRadius * 2 + xOffset)
        .attr("height", Styles.pieChartRadius * 2)

    # Draw the pie chart
    drawPieChart vis, data, Styles.pieChartRadius, 
      x: Styles.pieChartRadius + xOffset

    # Draw labels on the pie chart
    labelData = [
      text: "protein"
      color: Styles.colors.blueText
    ,
      text: "carbs"
      color: Styles.colors.greenText
    ,
      text: "fat"
      color: Styles.colors.redText
    ]

    vis.selectAll("text.pie-chart-legend-label")
      .data(labelData)
      .enter()
        .append("text")
        .attr("class", "pie-chart-legend-label")
        .attr("x", -Styles.pieChartRadius - Styles.horizontalPadding)
        .attr("y", (d, i) -> i * Styles.smallFontLineHeight - 8)
        .attr("text-anchor", "end")
        .text((d) -> d.text)
        .style("font-size", Styles.smallFontSize)
        .style("fill", (d) -> d.color)


# Displays a list of foods' nutrients relative to one another.
visuals.directive "foodComparison", (Styles, FoodData) ->

  barGraphKeys = FoodData.vitaminKeys.concat(FoodData.mineralKeys).concat(FoodData.aminoAcidKeys)

  restrict: "E"
  templateUrl: "partials/food-comparison.html"
  scope:
    foodData: "="
  link: (scope, element, attrs) ->

    vis = d3.select(element[0]).select(".food-comparison-graph")
      .append("svg")
        .attr("width", barGraphKeys.length * Styles.comparisonCellWidth)
        .attr("height", Styles.comparisonHeaderHeight)

    render = ->
      # Clear the visualization
      vis.selectAll("*").remove()

      numSelected = scope.foodData.selectedFoods.length

      # Set the height based on the number of selected foods
      height = Styles.comparisonHeaderHeight + Styles.comparisonRowHeight * numSelected
      
      # Make room for the visualization key if there are items
      if numSelected > 0
        height += Styles.comparisonRowHeight
      
      vis.attr("height", height)

      return unless numSelected

      # Draw each nutrient section label
      vitaminsWidth = FoodData.vitaminKeys.length * Styles.comparisonCellWidth
      mineralsWidth = FoodData.mineralKeys.length * Styles.comparisonCellWidth
      aminoAcidsWidth = FoodData.aminoAcidKeys.length * Styles.comparisonCellWidth
      nutrientSectionData = [
        text: "vitamins"
        color: Styles.colors.green
        width: vitaminsWidth
        x: 0
        midpoint: vitaminsWidth / 2
      ,
        text: "minerals"
        color: Styles.colors.violet
        width: mineralsWidth
        x: vitaminsWidth
        midpoint: vitaminsWidth + (mineralsWidth / 2)
      ,
        text: "amino acids"
        color: Styles.colors.blue
        width: aminoAcidsWidth
        x: vitaminsWidth + mineralsWidth
        midpoint: vitaminsWidth + mineralsWidth + (aminoAcidsWidth / 2)
      ]
      vis.selectAll("text.nutrient-section-label")
        .data(nutrientSectionData)
        .enter()
          .append("text")
            .attr("y", height - 12)
            .attr("x", (d) -> d.midpoint)
            .attr("class", "nutrient-section-label")
            .attr("text-anchor", "middle")
            .style("font-size", Styles.largeFontSize)
            .style("fill", (d) -> d.color)
            .text((d) -> d.text)

      # Draw the nutrient section demarcations
      vis.selectAll("rect.nutrient-section-demarcation")
        .data(nutrientSectionData)
        .enter()
          .append("rect")
            .attr("y", height - Styles.comparisonRowHeight)
            .attr("x", (d) -> d.x)
            .attr("width", (d) -> d.width)
            .attr("height", 3)
            .style("fill", (d) -> d.color)

      # Draw each nutrient label
      vis.selectAll("text.nutrient-label")
        .data(barGraphKeys)
        .enter()
          .append("text")
            .attr("onclick", "javascript: alert('TODO: nutrient detail')")
            .attr("class", "nutrient-label")
            .attr("transform", "rotate(-90)")
            .attr("x", -Styles.comparisonHeaderHeight + Styles.horizontalPadding)
            .attr("y", (d, i) -> i * Styles.comparisonCellWidth + 15)
            .style("font-size", Styles.smallFontSize)
            .text((d) -> FoodData.getKeyAlias(d))

      # Draw each item in the list
      for foodIndex in [0...numSelected]
        food = scope.foodData.selectedFoods[foodIndex]

        # Draw each data point
        for keyIndex in [0...barGraphKeys.length]
          key = barGraphKeys[keyIndex]
          value = food[key + "_Compared"]
          
          # Draw nothing if no data
          continue unless value?

          # Cycle through the rainbow colors
          rainbowIndex = keyIndex
          rainbowCount = Styles.colors.rainbow.length
          while rainbowIndex >= rainbowCount
            rainbowIndex -= rainbowCount
          color = Styles.colors.rainbow[rainbowIndex]

          # Calculate the y position for this food
          y = Styles.comparisonHeaderHeight + foodIndex * Styles.comparisonRowHeight
          
          # Create the background
          vis.append("rect")
            .attr("x", keyIndex * Styles.comparisonCellWidth)
            .attr("y", y)
            .attr("width", Styles.comparisonCellWidth)
            .attr("height", Styles.comparisonRowHeight)
            .attr("fill", color)
            .attr("opacity", 0.5)
            .attr("title", key)
          
          # Create the bar
          vis.append("rect")
            .attr("x", keyIndex * Styles.comparisonCellWidth)
            .attr("y", y)
            .attr("width", Styles.comparisonCellWidth * value)
            .attr("height", Styles.comparisonRowHeight)
            .attr("fill", color)
            .attr("title", key)

    # Redraw when items are selected or deselected
    scope.$watch "foodData.selectedFoods.length", ->
      render()
  

# Provides a search box and food list from which foods can be selected.
visuals.directive "foodSearch", (Styles) ->
  restrict: "E"
  templateUrl: "partials/food-search.html"
  scope:
    foodData: "="