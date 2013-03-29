# Nutrients Per Calorie is a web interface to the nutritional data available at http://ndb.nal.usda.gov/
# https://github.com/ryanatkn/nutrients-per-calorie
# Copyright (c) Ryan Atkinson 2013
# MIT License


###

Use cases
  [x] Compare n foods against one another.
    [x] Daily recommendation baseline
    [x] Comparison presets
    [ ] Option to show comparison graphs in search
  [x] What are the best sources of nutrient x?
  [ ] Compose meals that get added to the food list, choosing foods and their quantities.
  [.] Do the above with food set x. (vegan, vegetarian, raw, natural, etc)

###

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
    .when "/options",
      templateUrl: "partials/options.html"
      controller: "OptionsCtrl"
    .otherwise redirectTo: "/compare"


app.controller "MainCtrl", ($scope, $location, FoodData, ComparePage, NutrientsPage) ->
  $scope.foodData = FoodData

  $scope.navLinks = _.extend [
    text: "Compare"
    getPath: ComparePage.getPath
  ,
    text: "Nutrients"
    getPath: NutrientsPage.getPath
  ,
    text: "About"
    getPath: -> "#/about"
  ,
    text: "Options"
    getPath: -> "#/options"
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
      !!_.find data.selectedFoods, (f) -> f.NDB_No is food.NDB_No
    toggle: (food) ->
      if data.isSelected(food)
        data.deselect food
      else
        data.select food
    deselect: (food) ->
      data.selectedFoods = _.reject(data.selectedFoods, (f) -> f.NDB_No is food.NDB_No)
      save()
    select: (food) ->
      data.deselect food
      data.selectedFoods.push _.clone(food)
      save()
    clear: ->
      for food in data.selectedFoods.slice(1)
        FoodData.findFoodById(food.NDB_No).selected = false
      data.reset()
    reset: (foods) ->
      data.selectedFoods = if FoodData.benchmarkFood then [FoodData.benchmarkFood] else []
      if foods
        data.selectedFoods = data.selectedFoods.concat(foods)
      save()
    basePath: "#/compare"
    updatePath: ->
      window.location.hash = data.getPath()
    getPath: (foods = data.selectedFoods.slice(1)) ->
      data.basePath + data.getSearch(foods)
    getSearch: (foods = data.selectedFoods.slice(1)) ->
      if foods.length
        "?foods=" + _.pluck(foods, "NDB_No").join(",")
      else
        ""
    getPathWithFoodAdded: (food) ->
      if food
        foods = _.clone(data.selectedFoods)
        if !_.find(foods, (f) -> f.NDB_No is food.NDB_No)
          foods.push food
        data.getPath foods
      else
        data.basePath

  # Try to load selected foods from localStorage
  saveKey = "selectedFoods"
  selectedFoods = window.localStorage.getItem(saveKey)
  if selectedFoods
    data.selectedFoods = JSON.parse(selectedFoods)
  save = -> window.localStorage.setItem saveKey, JSON.stringify(data.selectedFoods)

  data


app.controller "CompareCtrl", ($scope, $routeParams, $timeout, FoodData, ComparePage, Presets) ->
  
  FoodData.afterLoading $scope, ->
    foods = null
    if $routeParams.foods
      foods = FoodData.findFoodsById($routeParams.foods.split(","))
    ComparePage.reset foods

  $scope.ComparePage = ComparePage

  $scope.$watch "ComparePage.selectedFoods", (newVal, oldVal) ->
    FoodData.calculateRelativeValues newVal
    ComparePage.updatePath() if FoodData.loaded

  $scope.hasSelectedFoods = -> ComparePage.selectedFoods.length > 1

  $scope.newPresetName = ""
  $scope.Presets = Presets
  $scope.createPreset = (name) ->
    if !$scope.hasSelectedFoods()
      alert "Choose some foods before saving the set."
    else if !name
      alert "Please name the set of foods to save it."
    else
      Presets.create name
      $scope.newPresetName = ""
  $scope.removePreset = (preset) ->
    $timeout -> # hack that prevents the dropdown from closing -- the remove button gets removed from the DOM, so the dropdown thinks something outside of it was clicked
      Presets.remove preset
    , 0

  $scope.isRemoveable = (food) ->
    food.NDB_No isnt "0"


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
      save()
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

  # Try to load selected nutrient from localStorage
  saveKey = "selectedNutrient"
  selectedNutrient = window.localStorage.getItem(saveKey)
  if selectedNutrient
    data.selectedNutrient = JSON.parse(selectedNutrient)
  save = -> window.localStorage.setItem saveKey, JSON.stringify(data.selectedNutrient)

  data

app.controller "NutrientsCtrl", ($scope, $routeParams, $filter, FoodData, NutrientsPage, ComparePage) ->
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


app.factory "OptionsPage", (FoodData) ->
  data =
    setActiveDatabase: (database) ->
      if FoodData.databases.getActive() isnt database
        FoodData.databases.setActive database
    getActiveDatabase: -> FoodData.databases.getActive().name


app.controller "OptionsCtrl", ($scope, OptionsPage, FoodData) ->
  $scope.options = OptionsPage

  
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

    FoodData.afterLoading scope, ->
      scope.foodGroups = FoodData.foodGroups
      scope.enableAllFoodGroups = FoodData.areAllFoodGroupsEnabled()

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
app.directive "mmInputClearer", ->
  link: (scope, element, attrs) ->
    inputClearer = angular.element("<div class='input-clearer'>✕</div>")
    inputClearer.on "click", ->
      element.val("").focus().trigger("input") # the trigger is needed to tell angular to sync the input's model :/
    element.after inputClearer


# Adds dropdown functionality to an element.
# Performs no transclusion - you must manually call `toggle` from a child element.
# CSS requires children with the classes `dropdown-toggle` and `dropdown-content`.
app.directive "mmDropdown", (FoodData) ->
  restrict: "C"
  link: (scope, element, attrs) ->

    onClick = (e) ->
      if element.hasClass("open") and element isnt e.target and !element.find(e.target).length
        scope.toggle()
      true

    FoodData.afterLoading scope, ->
      $(window).on "click", onClick

    scope.toggle = ->
      element.toggleClass "open"

    scope.$on "$destroy", ->
      $(window).off "click", onClick


# Evalulates `mm-keydown` when one of the space-separated `mm-key-codes` are pressed.
app.directive "mmKeydown", ->
  link: (scope, element, attrs) ->
    element.on "keydown", (e) ->
      if _.contains(attrs.mmKeyCodes.split(" "), e.keyCode.toString())
        scope.$apply ->
          scope.$eval attrs.mmKeydown
      true