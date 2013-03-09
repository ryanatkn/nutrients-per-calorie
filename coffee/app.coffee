# Nutrients Per Calorie is a web interface to the nutritional data available at http://ndb.nal.usda.gov/
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
      reloadOnSearch: false
    .when "/compare/:foods",
      templateUrl: "partials/compare.html"
      controller: "CompareCtrl"
      reloadOnSearch: false
    .when "/foods",
      templateUrl: "partials/foods.html"
      controller: "FoodsCtrl"
      reloadOnSearch: false
    .when "/foods/:food",
      templateUrl: "partials/foods.html"
      controller: "FoodsCtrl"
      reloadOnSearch: false
    .when "/nutrients",
      templateUrl: "partials/nutrients.html"
      controller: "NutrientsCtrl"
      reloadOnSearch: false
    .when "/nutrients/:nutrient",
      templateUrl: "partials/nutrients.html"
      controller: "NutrientsCtrl"
      reloadOnSearch: false
    .when "/about",
      templateUrl: "partials/about.html"
    .otherwise redirectTo: "/compare"


app.controller "MainCtrl", ($scope, $location, FoodData, ComparePage, FoodsPage, NutrientsPage) ->
  $scope.foodData = FoodData

  $scope.navLinks = _.extend [
    text: "Compare"
    getPath: ComparePage.getPath
  ,
    text: "Foods"
    getPath: FoodsPage.getPath
  ,
    text: "Nutrients"
    getPath: NutrientsPage.getPath
  ,
    text: "About"
    getPath: -> "#/about"
  ],
    isActive: (navLink) ->
      _.contains navLink.getPath(), $location.path()


app.factory "ComparePage", ($location, FoodData) ->
  data = 
    query:
      text: ""
      includeFoodGroups: false
    selectedFoods: []
    isSelected: (food) ->
      !!_.find @selectedFoods, (f) -> f.NDB_No is food.NDB_No
    toggle: (food) ->
      if @isSelected(food)
        @selectedFoods = _.reject(@selectedFoods, (f) -> f.NDB_No is food.NDB_No)
      else
        @selectedFoods = _.union(@selectedFoods, _.clone(food))
    clear: ->
      for food in @selectedFoods
        FoodData.findFoodById(food.NDB_No).selected = false
      @selectedFoods = []
    basePath: "#/compare"
    updatePath: ->
      window.location.hash = @getPath()
    getPath: (foods = data.selectedFoods) ->
      data.basePath + data.getSearch(foods)
    getSearch: (foods = data.selectedFoods) ->
      if foods.length
        "?foods=" + _.pluck(foods, "NDB_No").join(",")
      else
        ""
    getPathWithFoodAdded: (food) ->
      if food
        foods = _.clone(@selectedFoods)
        if !_.find(foods, (f) -> f.NDB_No is food.NDB_No)
          foods.push food
        @getPath foods
      else
        @basePath


app.controller "CompareCtrl", ($scope, $routeParams, FoodData, ComparePage) ->
  
  FoodData.afterLoading $scope, ->
    if $routeParams.foods
      ComparePage.selectedFoods = _.clone(FoodData.findFoodsById($routeParams.foods.split(",")))
    else
      ComparePage.selectedFoods = []

  $scope.compare = ComparePage

  $scope.$watch "compare.selectedFoods", (newVal, oldVal) ->
    FoodData.calculateRelativeValues newVal
    ComparePage.updatePath() if FoodData.loaded


app.factory "FoodsPage", ($location) ->
  data =
    query:
      text: ""
      includeFoodGroups: false
    selectedFood: null
    isSelected: (food) ->
      @selectedFood?.NDB_No is food?.NDB_No
    toggle: (food) ->
      if @isSelected(food)
        @selectedFood = null
      else
        @selectedFood = _.clone(food)
    basePath: "#/foods"
    updatePath: ->
      window.location.hash = @getPath()
    getPath: (food = data.selectedFood) ->
      data.basePath + data.getSearch(food)
    getSearch: (food = data.selectedFood) ->
      if food
        "?food=" + food.NDB_No
      else
        ""


app.controller "FoodsCtrl", ($scope, $routeParams, FoodData, FoodsPage) ->
  
  FoodData.afterLoading $scope, ->
    if $routeParams.food
      FoodsPage.selectedFood = _.clone(FoodData.findFoodById($routeParams.food))
    else
      FoodsPage.selectedFood = null

  $scope.foods = FoodsPage

  $scope.$watch "foods.selectedFood", (newVal, oldVal) ->
    FoodsPage.updatePath() if FoodData.loaded


app.factory "NutrientsPage", ($location, FoodData) ->
  data = 
    query:
      text: ""
      includeFoodGroups: false
    selectedNutrient: null
    filteredFoods: FoodData.foods
    isSelected: (nutrient) ->
      nutrient?.Nutr_No is @selectedNutrient?.Nutr_No
    toggle: (nutrient) ->
      if @isSelected(nutrient)
        @selectedNutrient = null
      else
        @selectedNutrient = _.clone(nutrient)
    orderBy: (food) ->
      value = food.nutrientValue
      if value?
        value
      else
        -1
    basePath: "#/nutrients"
    updatePath: ->
      window.location.hash = @getPath()
    getPath: (nutrient = data.selectedNutrient) ->
      data.basePath + data.getSearch(nutrient)
    getSearch: (nutrient = data.selectedNutrient) ->
      if nutrient
        "?nutrient=" + nutrient.Nutr_No
      else
        ""


app.controller "NutrientsCtrl", ($scope, $routeParams, $filter, FoodData, NutrientsPage) ->

  FoodData.afterLoading $scope, ->
    if $routeParams.nutrient
      NutrientsPage.selectedNutrient = _.clone(FoodData.findNutrientById($routeParams.nutrient))
    else
      NutrientsPage.selectedNutrient = null

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
    return if !FoodData.loaded
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
    NutrientsPage.updatePath()

  $scope.$watch "nutrients.query.text", (newVal, oldVal) ->
    updateFilteredFoods true

  $scope.$watch "nutrients.selectedNutrient", (newVal, oldVal) ->
    updateFilteredFoods()

  $scope.$watch "nutrients.query.includeFoodGroups", (newVal, oldVal) ->
    updateFilteredFoods true

  $scope.$watch "foodData.foods", (newVal, oldVal) ->
    updateFilteredFoods true

  
# Provides a search box and food list from which foods can be selected.
app.directive "foodSearch", ->
  restrict: "E"
  templateUrl: "partials/food-search.html"
  scope:
    foodData: "="
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


# Provides a dropdown with food group checkboxes to filter the food search.
app.directive "foodGroupFilter", (FoodData) ->
  supressEnableAllChange = false

  restrict: "E"
  templateUrl: "partials/food-group-filter.html"
  scope:
    foodData: "="
  link: (scope, element, attrs) ->

    onClick = (e) ->
      if element.hasClass("open") and element isnt e.target and !element.find(e.target).length
        scope.toggle()
      true

    FoodData.afterLoading scope, ->
      scope.foodGroups = FoodData.foodGroups
      $(window).on "click", onClick
      scope.enableAllFoodGroups = FoodData.areAllFoodGroupsEnabled()

    scope.toggle = ->
      element.toggleClass "open"

    scope.$on "$destroy", ->
      $(window).off "click", onClick

    scope.$watch "foodGroups", (newVal, oldVal) ->
      FoodData.updateFoodGroups()

      # Update the "All food groups" checkbox
      if scope.enableAllFoodGroups and FoodData.areAllFoodGroupsEnabled(oldVal) and 
          !FoodData.areAllFoodGroupsEnabled(newVal) and FoodData.getFoodGroupsEnabledCount(newVal) > 0
        supressEnableAllChange = true
        scope.enableAllFoodGroups = false
      if !scope.enableAllFoodGroups and FoodData.areAllFoodGroupsEnabled(newVal) and
          !FoodData.areAllFoodGroupsEnabled(oldVal) and FoodData.getFoodGroupsEnabledCount(oldVal) > 0
        supressEnableAllChange = true
        scope.enableAllFoodGroups = true
    , true # deep watch...

    scope.$watch "enableAllFoodGroups", (newVal, oldVal) ->
      if supressEnableAllChange
        supressEnableAllChange = false
        return
      if newVal isnt oldVal
        for foodGroup in FoodData.foodGroups
          foodGroup.enabled = newVal


# Searches the `Long_Desc` field of the foods list, including `FdGrp_Desc` if includeFoodGroups is true
# The search text is case- and order-insensitive
# The characters in `negativeSearchPrefixes` exclude results
app.filter "searchFoods", ->
  (foods, query) ->
    {text, includeFoodGroups} = query
    if text and typeof text is "string"
      text = text.replace(/[^a-zA-Z0-9.,%\-! ]/g, "")
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


# Adds an X to text input fields for quick clearing.
app.directive "inputClearer", ->
  link: (scope, element, attrs) ->
    inputClearer = angular.element("<div class='input-clearer'>✕</div>")
    inputClearer.on "click", ->
      element.val("").focus().trigger("input") # the trigger is needed to tell angular to sync the input's model :/
    element.after inputClearer