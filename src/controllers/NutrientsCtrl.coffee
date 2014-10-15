module.exports = ($scope, $routeParams, $filter, FoodData, NutrientsPage, ComparePage) ->
  FoodData.afterLoading $scope, ->
    if $routeParams.nutrient
      NutrientsPage.selectedNutrient = _.clone(FoodData.findNutrientById($routeParams.nutrient))
    else
      NutrientsPage.selectedNutrient = null

  $scope.NutrientsPage = NutrientsPage

  $scope.nutrientKeyLists = [
    FoodData.macronutrientKeys
    FoodData.vitaminKeys
    FoodData.mineralKeys
    FoodData.aminoAcidKeys
    FoodData.miscKeys
    FoodData.fattyAcidKeys
    FoodData.sugarKeys
    FoodData.otherKeys
  ]

  $scope.selectFood = (food) ->
    ComparePage.select food
    ComparePage.updatePath() # bc the compare controller isn't alive to watch for changes

  filteredFoodsWithoutValues = null
  maxValue = null

  calculateMaxValue = (nutrient) ->
    if nutrient and filteredFoodsWithoutValues.length
      max = 0
      for food in filteredFoodsWithoutValues
        value = food[nutrient.NutrDesc]
        if typeof value is "number" and value > max
          max = value
      max
    else
      null

  updateFilteredFoods = (applyFilter) ->
    return if !FoodData.loaded
    if applyFilter
      filteredFoodsWithoutValues = $filter("searchFoods")(FoodData.foods, NutrientsPage.query)
    else
      filteredFoodsWithoutValues ?= FoodData.foods
    selectedNutrient = NutrientsPage.selectedNutrient
    maxValue = calculateMaxValue(selectedNutrient)
    NutrientsPage.filteredFoods = if selectedNutrient
      _.map filteredFoodsWithoutValues, (f) ->
        food =
          NDB_No: f.NDB_No
          Long_Desc: f.Long_Desc
          FdGrp_Desc: f.FdGrp_Desc
        food.nutrientValue = f[selectedNutrient.NutrDesc] or 0
        food.nutrientPercentOfMax = if maxValue then ((food.nutrientValue / maxValue) * 100) + "%" else "0%"
        food
    else
      []
    NutrientsPage.updatePath()

  $scope.$watch "NutrientsPage.query.text", (newVal, oldVal) ->
    updateFilteredFoods true

  $scope.$watch "NutrientsPage.selectedNutrient", (newVal, oldVal) ->
    updateFilteredFoods()

  $scope.$watch "NutrientsPage.query.includeFoodGroups", (newVal, oldVal) ->
    updateFilteredFoods true

  $scope.$watch "foodData.foods", (newVal, oldVal) ->
    updateFilteredFoods true