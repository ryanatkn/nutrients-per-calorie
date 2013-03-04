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

  $scope.data =
    compare:
      foods: []
      query:
        text: ""
        includeFoodGroups: false
      getHash: -> routes.compare + @foods.join("+")
      toggle: (food) ->
        food = FoodData.findFoodById(food.NDB_No)
        if not food.selected
          food.selected = true
          @foods.push _.clone(food) # clone so we can add relative values without polluting the singleton data
        else
          food.selected = false
          @foods = _.reject(@foods, (f) -> f.NDB_No is food.NDB_No)
        FoodData.calculateRelativeValues @foods
        @
      clear: ->
        for food in @foods
          FoodData.findFoodById(food.NDB_No).selected = false
        @foods = []
        @
    foods:
      selected: null
    nutrients:
      selected: null


app.controller "CompareCtrl", ($scope, $routeParams) ->
  console.log "COMPARE CTRL", $routeParams


app.controller "FoodsCtrl", ($scope, $routeParams, FoodData) ->
  if $routeParams.food
    $scope.data.foods.selected = FoodData.findFoodById($routeParams.food)


app.controller "NutrientsCtrl", ($scope, $routeParams, FoodData) ->
  if $routeParams.nutrient
    $scope.data.nutrients.selected = FoodData.findNutrientById($routeParams.nutrient)

  
# Provides a search box and food list from which foods can be selected.
app.directive "foodSearch", (Styles) ->
  restrict: "E"
  templateUrl: "partials/food-search.html"


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