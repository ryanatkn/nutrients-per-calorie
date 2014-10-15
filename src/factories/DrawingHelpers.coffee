module.exports = (Styles, FoodData, $location, $filter) ->

  # Draws a pie chart from `data` on the `svg` with the given `radius`.
  # Returns the d3 visualization.
  drawPieChart = (svg, data, radius, options = {}) ->
    {x, y} = options
    x ?= radius
    y ?= radius

    g = svg.append("g")
      .data([data])
      .attr("transform", "translate(#{x}, #{y})")

    arc = d3.svg.arc()
      .outerRadius(radius)

    pie = d3.layout.pie()
      .value((d) -> d.value)
      .sort((d) -> data.indexOf(d))

    arcs = g.selectAll("g.slice")
      .data(pie)
      .enter()
        .append("g")
          .attr("class", "slice")

    arcs.append("path")
      .attr("fill", (d, i) -> d.data.color)
      .attr("d", arc)

  # Draws a vertical list of pie charts and a legend for the given foods
  drawPieCharts = (vis, foods) ->
    svg = vis.append("svg")
      .attr("height", vis.attr("height"))
      .attr("width", (Styles.pieChartRadius * 2) + Styles.comparisonHorizontalSpacing)

    # Displays the pie chart labels to explain how to interpret them.
    labelData = [
      text: "Protein"
      color: Styles.colors.blueText
      NutrDesc: "Protein"
    ,
      text: "Carbs"
      color: Styles.colors.greenText
      NutrDesc: "Carbohydrate, by difference"
    ,
      text: "Fat"
      color: Styles.colors.redText
      NutrDesc: "Total lipid (fat)"
    ]
    svg.selectAll("text.pie-chart-legend-label")
      .data(labelData)
      .enter()
        .append("text")
        .attr("class", "pie-chart-legend-label nutrient-label")
        .attr("x", (parseInt(svg.attr("width")) - Styles.comparisonHorizontalSpacing) / 2)
        .attr("y", (d, i) -> (i * Styles.smallFontLineHeight) + Styles.comparisonRowHeight)
        .attr("text-anchor", "middle")
        .style("font-size", Styles.smallFontSize)
        .style("fill", (d) -> d.color)
        .text((d) -> d.text)
        .attr("onclick", (d) -> FoodData.getNutrientJSLink(d.NutrDesc))

    # Draw each item in the list
    for foodIndex in [0...foods.length]
      food = foods[foodIndex]
      foodY = Styles.comparisonHeaderHeight + foodIndex * Styles.comparisonRowHeight

      # Draw the pie chart
      pieChartData = [
        value: food["Total lipid (fat)"]
        color: Styles.colors.red
      ,
        value: food["Protein"]
        color: Styles.colors.blue
      ,
        value: food["Carbohydrate, by difference"]
        color: Styles.colors.green
      ,
        value: food["Alcohol, ethyl"]
        color: Styles.colors.lightGray
      ]
      drawPieChart svg, pieChartData, Styles.pieChartRadius,
        x: Styles.pieChartRadius
        y: foodY + Styles.pieChartRadius

      # Draw the % protein
      svg.append("text")
        .text($filter("percent")(food.Protein))
        .attr("fill", Styles.colors.blueText)
        .style("font-size", Styles.smallFontSize)
        .attr("x", Styles.pieChartRadius * 2 + 7)
        .attr("y", foodY + Styles.pieChartRadius + 4)
        .attr("text-anchor", "left")

  # Draws a set of nutrients
  drawNutrients = (vis, foods, nutrients) ->
    vis.append("text")
      .attr("y", parseInt(vis.attr("height")) - 12)
      .attr("x", (parseInt(vis.attr("width")) - Styles.comparisonHorizontalSpacing) / 2)
      .attr("class", "nutrient-section-label")
      .attr("text-anchor", "middle")
      .style("font-size", Styles.largeFontSize)
      .style("fill", nutrients.color)
      .text(switch nutrients.text
        when "Fiber" then ""
        else nutrients.text)

    # Draw each nutrient label
    getLabelX = (i) -> i * Styles.comparisonCellWidth + 9
    labelY = Styles.comparisonHeaderHeight + Styles.horizontalPadding - 8
    vis.selectAll("text.nutrient-label")
      .data(nutrients)
      .enter()
        .append("text")
          .attr("class", "nutrient-label")
          .attr("transform", (d, i) -> 
            "rotate(-45 #{getLabelX(i)} #{labelY})")
          .attr("x", (d, i) -> getLabelX(i))
          .attr("y", labelY)
          .style("font-size", Styles.smallFontSize)
          .style("fill", (d, i) -> Styles.colors.getRainbowColor(i))
          .text((d) -> FoodData.nutrients[d].text)
          .attr("onclick", (d) -> FoodData.getNutrientJSLink(d))

     # Draw each item in the list
    for foodIndex in [0...foods.length]
      food = foods[foodIndex]
      foodY = Styles.comparisonHeaderHeight + (foodIndex * Styles.comparisonRowHeight)

      # Draw each bar graph data point
      for keyIndex in [0...nutrients.length]
        key = nutrients[keyIndex]
        value = food[key + "_Compared"]
        
        # Draw nothing if no data
        continue unless value?

        # Cycle through the rainbow colors
        color = Styles.colors.getRainbowColor(keyIndex)

        nutrientX = keyIndex * Styles.comparisonCellWidth
        
        # Create the background
        vis.append("rect")
          .attr("x", nutrientX)
          .attr("y", foodY)
          .attr("width", Styles.comparisonCellWidth)
          .attr("height", Styles.comparisonRowHeight)
          .attr("fill", "#000")
          .attr("opacity", 0.08)
          .attr("title", key)
        
        # Create the bar
        vis.append("rect")
          .attr("x", nutrientX + (Styles.comparisonCellWidth / 2) - (((Styles.comparisonCellWidth * value)) / 2))
          .attr("y", foodY)
          .attr("width", Styles.comparisonCellWidth * value)
          .attr("height", Styles.comparisonRowHeight)
          .attr("fill", color)
          .attr("title", key)

  # Draws every array of nutrients in `groups`
  drawNutrientGroups = (vis, foods, groups) ->
    for nutrients in groups
      svg = vis.append("svg")
        .attr("width", (nutrients.length * Styles.comparisonCellWidth) + Styles.comparisonHorizontalSpacing)
        .attr("height", parseInt(vis.attr("height")))
      DrawingHelpers.drawNutrients svg, foods, nutrients
    
  DrawingHelpers = {
    drawPieChart
    drawPieCharts
    drawNutrients
    drawNutrientGroups
  }