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


app.controller "CompareCtrl", ($scope, $routeParams, FoodData) ->
  $scope.compare =
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


app.controller "FoodsCtrl", ($scope, $routeParams, FoodData) ->
  if $routeParams.food
    $scope.foods.selected = FoodData.findFoodById($routeParams.food)

  $scope.foods =
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


app.controller "NutrientsCtrl", ($scope, $routeParams, FoodData) ->
  if $routeParams.nutrient
    $scope.nutrients.selected = FoodData.findNutrientById($routeParams.nutrient)

  $scope.nutrients =
    query:
      text: ""
      includeFoodGroups: false
    selectedNutrient: null
    getMaxValue: ->
      if @selectedNutrient
        console.log "get max"
        _.max(FoodData.foods, @selectedNutrient.NutrDesc)[@selectedNutrient.NutrDesc]
      else
        null
    getPercentOfMax: (food) ->
      if @selectedNutrient
        ((food[@selectedNutrient.NutrDesc] / @getMaxValue()) * 100) + "%"
      else
        null
    selected: (nutrient) ->
      nutrient?.Nutr_No is @selectedNutrient?.Nutr_No
    toggle: (nutrient) ->
      if @selected(nutrient)
        @selectedNutrient = null
      else
        @selectedNutrient = _.clone(nutrient)
    getNutrientData: (food) ->
      if @selectedNutrient
        food[@selectedNutrient.NutrDesc]
      else
        null
    orderBy: (food) ->
      value = food[$scope.nutrients.selectedNutrient?.NutrDesc]
      if value?
        value
      else
        -1

  
# Provides a search box and food list from which foods can be selected.
app.directive "foodSearch", ->
  restrict: "E"
  templateUrl: "partials/food-search.html"
  scope:
    foods: "="
    helpers: "="
    

app.directive "nutrientList", (FoodData) ->
  restrict: "E"
  templateUrl: "partials/nutrient-list.html"
  scope:
    nutrientKeys: "="
    helpers: "="
  link: (scope, element, attrs) ->
    scope.nutrients = _.map(scope.nutrientKeys, (n) -> FoodData.nutrients[n])


# Searches the `Long_Desc` field of the foods list, including `FdGroup_Desc` if includeFoodGroups is true
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