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

  $scope.navLinks = _.extend [
    text: "Compare"
    href: "#/compare"
  ,
    text: "Foods"
    href: "#/foods"
  ,
    text: "Nutrients"
    href: "#/nutrients"
  ,
    text: "About"
    href: "#/about"
  ],
    isActive: (navLink) ->
      _.contains "#" + $location.path(), navLink.href


app.controller "CompareCtrl", ($scope, $routeParams) ->
  console.log "COMPARE CTRL", $routeParams


app.controller "FoodsCtrl", ($scope, $routeParams, FoodData) ->
  $scope.foods = 
    selected: if $routeParams.food then FoodData.findFoodById($routeParams.food) else null


app.controller "NutrientsCtrl", ($scope, $routeParams, FoodData) ->
  $scope.nutrients =
    selected: if $routeParams.nutrient then FoodData.findNutrientById($routeParams.nutrient) else null


# Searches the `Long_Desc` field of the foods list, including `FdGroup_Desc` if includeFoodGroups is true
# The search text is case- and order-insensitive
# The characters in `negativeSearchPrefixes` exclude results
app.filter "searchFoods", ->
  (foods, searchQuery) ->
    {text, includeFoodGroups} = searchQuery
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