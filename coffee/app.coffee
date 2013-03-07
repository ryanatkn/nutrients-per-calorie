# Nutrients Per Calorie is an interface to the nutritional data available at http://ndb.nal.usda.gov/
# https://github.com/ryanatkn/nutrients-per-calorie
# Copyright (c) Ryan Atkinson 2013
# MIT License


# Use cases
# [x] Compare n foods against one another.
# [ ] What are the best sources of nutrient x?
# [ ] What does food x look like in detail?
# [ ] Do the above with food set x. (vegan, vegetarian, raw, natural, etc)


app = angular.module("nutrients-per-calorie", ["food-visuals", "food-data"])


app.config ($routeProvider) ->
  $routeProvider
    .when "/compare",
      templateUrl: "partials/compare.html"
      controller: "CompareCtrl"
    .when "/compare/:foods",
      templateUrl: "partials/compare.html"
      controller: "CompareCtrl"
    .when "/foods",
      templateUrl: "partials/foods.html"
      controller: "FoodsCtrl"
    .when "/foods/:food",
      templateUrl: "partials/foods.html"
      controller: "FoodsCtrl"
    .when "/nutrients",
      templateUrl: "partials/nutrients.html"
      controller: "NutrientsCtrl"
    .when "/nutrients/:nutrient",
      templateUrl: "partials/nutrients.html"
      controller: "NutrientsCtrl"
    .when "/about",
      templateUrl: "partials/about.html"
    .otherwise redirectTo: "/compare"


app.controller "MainCtrl", ($scope, $location, FoodData) ->
  $scope.foodData = FoodData

  routes =
    compare:   "#/compare"
    foods:     "#/foods"
    nutrients: "#/nutrients"
    about:     "#/about"

  $scope.navLinks = _.extend [
    text: "Compare"
    href: routes.compare
    getHash: -> 
      routes.compare + $scope.compare.selectedFoods.join("+")
  ,
    text: "Foods"
    href: routes.foods
  ,
    text: "Nutrients"
    href: routes.nutrients
  ,
    text: "About"
    href: routes.about
  ],
    isActive: (navLink) ->
      _.contains "#" + $location.path(), navLink.href


app.factory "ComparePage", (FoodData) ->
  query:
    text: ""
    includeFoodGroups: false
  selectedFoods: []
  selected: (food) ->
    !!_.find @selectedFoods, (f) -> f.NDB_No is food.NDB_No
  toggle: (food) ->
    if @selected(food)
      @selectedFoods = _.reject(@selectedFoods, (f) -> f.NDB_No is food.NDB_No)
    else
      @selectedFoods.push _.clone(food)
    FoodData.calculateRelativeValues @selectedFoods
  clear: ->
    for food in @selectedFoods
      FoodData.findFoodById(food.NDB_No).selected = false
    @selectedFoods = []


app.controller "CompareCtrl", ($scope, $routeParams, FoodData, ComparePage) ->
  $scope.compare = ComparePage


app.factory "FoodsPage", ->
  query:
    text: ""
    includeFoodGroups: false
  selectedFood: null
  selected: (food) ->
    @selectedFood?.NDB_No is food?.NDB_No
  toggle: (food) ->
    if @selected(food)
      @selectedFood = null
    else
      @selectedFood = _.clone(food)


app.controller "FoodsCtrl", ($scope, $routeParams, FoodData, FoodsPage) ->
  if $routeParams.food
    $scope.foods.selectedFood = FoodData.findFoodById($routeParams.food)

  $scope.foods = FoodsPage


app.factory "NutrientsPage", (FoodData) ->
  query:
    text: ""
    includeFoodGroups: false
  selectedNutrient: null
  filteredFoods: FoodData.foods
  selected: (nutrient) ->
    nutrient?.Nutr_No is @selectedNutrient?.Nutr_No
  toggle: (nutrient) ->
    if @selected(nutrient)
      @selectedNutrient = null
    else
      @selectedNutrient = _.clone(nutrient)
  orderBy: (food) ->
    value = food.nutrientValue
    if value?
      value
    else
      -1


app.controller "NutrientsCtrl", ($scope, $routeParams, FoodData, $filter, NutrientsPage) ->
  if $routeParams.nutrient
    $scope.nutrients.selectedNutrient = FoodData.findNutrientById($routeParams.nutrient)

  $scope.nutrients = NutrientsPage

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
    if applyFilter
      filteredFoodsWithoutValues = $filter("searchFoods")(FoodData.foods, $scope.nutrients.query)
    else
      filteredFoodsWithoutValues ?= FoodData.foods
    selectedNutrient = $scope.nutrients.selectedNutrient
    maxValue = calculateMaxValue(selectedNutrient)
    $scope.nutrients.filteredFoods = if selectedNutrient
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

  $scope.$watch "nutrients.query.text", (newVal, oldVal) ->
    updateFilteredFoods true

  $scope.$watch "nutrients.selectedNutrient", (newVal, oldVal) ->
    updateFilteredFoods()

  $scope.$watch "nutrients.query.includeFoodGroups", (newVal, oldVal) ->
    updateFilteredFoods true

  
# Provides a search box and food list from which foods can be selected.
app.directive "foodSearch", ->
  restrict: "E"
  templateUrl: "partials/food-search.html"
  scope:
    foods: "="
    helpers: "="
    

# Provides a selectable list of nutrients.
app.directive "nutrientList", (FoodData) ->
  restrict: "E"
  templateUrl: "partials/nutrient-list.html"
  scope:
    nutrientKeys: "="
    helpers: "="
  link: (scope, element, attrs) ->
    scope.nutrients = _.map(scope.nutrientKeys, (n) -> FoodData.nutrients[n])


# Searches the `Long_Desc` field of the foods list, including `FdGrp_Desc` if includeFoodGroups is true
# The search text is case- and order-insensitive
# The characters in `negativeSearchPrefixes` exclude results
app.filter "searchFoods", ->
  (foods, query) ->
    {text, includeFoodGroups} = query
    if text
      filteredFoods = []
      negativeSearchPrefixes = ["!", "-"]
      words = text.split(" ")
      words = _.reject(words, (w) -> !w or w.length is 1 and _.contains(negativeSearchPrefixes, w))
      wordCount = words.length
      
      # Create the positive and negative regExps
      positiveRegExps = []
      negativeRegExps = []
      for word in words
        if not _.contains(negativeSearchPrefixes, word[0])
          positiveRegExps.push new RegExp(word, "i")
        else
          negativeRegExps.push new RegExp(word.slice(1), "i")
      
      # Look for matches
      for food in foods
        matchCount = 0
        for regExp in positiveRegExps
          if food.Long_Desc.match(regExp) or (includeFoodGroups and food.FdGrp_Desc.match(regExp))
            matchCount += 1
        for regExp in negativeRegExps
          if not food.Long_Desc.match(regExp) and not (includeFoodGroups and food.FdGrp_Desc.match(regExp))
            matchCount += 1
        if wordCount is matchCount
          filteredFoods.push food
      filteredFoods
    else
      foods


app.filter "percent", ->
  (number, decimals = 0) ->
    if number?
      multiple = Math.pow(10, decimals)
      ((Math.round(number * multiple * 100) / multiple)) + "%"
    else
      ""