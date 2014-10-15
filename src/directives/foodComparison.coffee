module.exports = (Styles, FoodData, DrawingHelpers) ->
  restrict: "E"
  templateUrl: "src/partials/food-comparison.html"
  link: (scope, element, attrs) ->

    vis = d3.select(element[0]).select(".food-comparison-graphs")

    render = ->
      vis.selectAll("*").remove()

      foods = scope.ComparePage.selectedFoods
      numSelected = foods.length
      if !numSelected
        vis.style "display", "none"
        return
      vis.style "display", "block"

      height = Styles.comparisonHeaderHeight + (Styles.comparisonRowHeight * (numSelected + 1))
      vis.attr "height", height

      DrawingHelpers.drawPieCharts vis, foods

      nutrientGroups = [
        FoodData.fiberKeys, FoodData.vitaminKeys, FoodData.mineralKeys,
        FoodData.aminoAcidKeys, FoodData.fattyAcidKeys, FoodData.miscKeys, FoodData.sugarKeys
      ]
      DrawingHelpers.drawNutrientGroups vis, foods, nutrientGroups

    # Redraw when items are selected or deselected
    scope.$watch "ComparePage.selectedFoods", ->
      render()