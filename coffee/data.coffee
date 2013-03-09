# Nutrients Per Calorie is a web interface to the nutritional data available at http://ndb.nal.usda.gov/
# https://github.com/ryanatkn/nutrients-per-calorie
# Copyright (c) Ryan Atkinson 2013
# MIT License


data = angular.module("food-data", [])


# Provides food data and related state from data/nutrients.csv and data/foods.csv
data.factory "FoodData", ($rootScope, Styles) ->

  allFoods = null

  allKeys = [
    "NDB_No", "Long_Desc", "FdGrp_Desc", "10:0" , "12:0", "13:0", "14:0", "14:1", "15:0",
    "15:1", "16:0", "16:1 c", "16:1 t", "16:1 undifferentiated", "17:0", "17:1", "18:0",
    "18:1 c", "18:1 t", "18:1 undifferentiated", "18:1-11t (18:1t n-7)", "18:2 CLAs",
    "18:2 i", "18:2 n-6 c,c", "18:2 t not further defined", "18:2 t,t", "18:2 undifferentiated",
    "18:3 n-3 c,c,c (ALA)", "18:3 n-6 c,c,c", "18:3 undifferentiated", "18:3i", "18:4", "20:0",
    "20:1", "20:2 n-6 c,c", "20:3 n-3", "20:3 n-6", "20:3 undifferentiated", "20:4 n-6",
    "20:4 undifferentiated", "20:5 n-3 (EPA)", "21:5", "22:0", "22:1 c", "22:1 t",
    "22:1 undifferentiated", "22:4", "22:5 n-3 (DPA)", "22:6 n-3 (DHA)", "24:0", "24:1 c",
    "4:0", "6:0", "8:0", "Adjusted Protein", "Alanine", "Alcohol, ethyl", "Arginine", "Ash",
    "Aspartic acid", "Betaine", "Beta-sitosterol", "Caffeine", "Calcium, Ca",
    "Campesterol", "Carbohydrate, by difference", "Carotene, alpha", "Carotene, beta", "Cholesterol",
    "Choline, total", "Copper, Cu", "Cryptoxanthin, beta", "Cystine", "Dihydrophylloquinone",
    "Energy", "Energy (kj)", "Fatty acids, total monounsaturated", "Fatty acids, total polyunsaturated",
    "Fatty acids, total saturated", "Fatty acids, total trans", "Fatty acids, total trans-monoenoic",
    "Fatty acids, total trans-polyenoic", "Fiber, total dietary", "Fluoride, F", "Folate, DFE",
    "Folate, food", "Folate, total", "Folic acid", "Fructose", "Galactose", "Glucose (dextrose)",
    "Glutamic acid", "Glycine", "Histidine", "Hydroxyproline", "Iron, Fe", "Isoleucine", "Lactose",
    "Leucine", "Lutein + zeaxanthin", "Lycopene", "Lysine", "Magnesium, Mg", "Maltose", "Manganese, Mn",
    "Menaquinone-4", "Methionine", "Niacin", "Pantothenic acid", "Phenylalanine", "Phosphorus, P",
    "Phytosterols", "Potassium, K", "Proline", "Protein", "Retinol", "Riboflavin", "Selenium, Se",
    "Serine", "Sodium, Na", "Starch", "Stigmasterol", "Sucrose", "Sugars, total", "Theobromine",
    "Thiamin", "Threonine", "Tocopherol, beta", "Tocopherol, delta", "Tocopherol, gamma", "Total lipid (fat)",
    "Tryptophan", "Tyrosine", "Valine", "Vitamin A, IU", "Vitamin A, RAE", "Vitamin B-12", "Vitamin B-12, added",
    "Vitamin B-6", "Vitamin C, total ascorbic acid", "Vitamin D", "Vitamin D (D2 + D3)",
    "Vitamin D2 (ergocalciferol)", "Vitamin D3 (cholecalciferol)", "Vitamin E (alpha-tocopherol)",
    "Vitamin E, added", "Vitamin K (phylloquinone)", "Water", "Zinc, Zn"
  ]

  keyAliases =
    "Total lipid (fat)":              "Fat"
    "Carbohydrate, by difference":    "Carbohydrate"
    "Fiber, total dietary":           "Fiber"
    "Alcohol, ethyl":                 "Alcohol"
    "Vitamin A, RAE":                 "Vitamin A" 
    "Vitamin C, total ascorbic acid": "Vitamin C"
    "Vitamin D (D2 + D3)":            "Vitamin D"
    "Vitamin E (alpha-tocopherol)":   "Vitamin E"
    "Vitamin K (phylloquinone)":      "Vitamin K"
    "Folate, total":                  "Folate"
    "Choline, total":                 "Choline"
    "Calcium, Ca":                    "Calcium"
    "Iron, Fe":                       "Iron"
    "Magnesium, Mg":                  "Magnesium"
    "Manganese, Mn":                  "Manganese"
    "Phosphorus, P":                  "Phosphorus"
    "Potassium, K":                   "Potassium"
    "Sodium, Na":                     "Sodium"
    "Zinc, Zn":                       "Zinc"
    "Glucose (dextrose)":             "Glucose"

  comparedKeys = _.difference(allKeys, ["NDB_No", "Long_Desc", "FdGrp_Desc"])

  macronutrientKeys = _.extend [
    "Total lipid (fat)"
    "Protein"
    "Carbohydrate, by difference"
    "Alcohol, ethyl"
  ],
    text: "Macronutrients"

  fiberKeys = _.extend [
    "Fiber, total dietary"
  ],
    text: "Fiber"
    color: Styles.colors.yellow

  vitaminKeys = _.extend [
    "Vitamin A, RAE"
    "Vitamin C, total ascorbic acid"
    "Vitamin D (D2 + D3)"
    "Vitamin E (alpha-tocopherol)"
    "Vitamin K (phylloquinone)"
    "Thiamin"
    "Riboflavin"
    "Niacin"
    "Pantothenic acid"
    "Vitamin B-6"
    "Folate, total"
    "Vitamin B-12"
  ],
    text: "Vitamins"
    color: Styles.colors.green

  mineralKeys = _.extend [
    "Calcium, Ca"
    "Iron, Fe"
    "Magnesium, Mg"
    "Manganese, Mn"
    "Phosphorus, P"
    "Potassium, K"
    "Sodium, Na"
    "Zinc, Zn"
  ],
    text: "Minerals"
    color: Styles.colors.violet

  aminoAcidKeys = _.extend [
    "Histidine"
    "Isoleucine"
    "Leucine"
    "Lysine"
    "Methionine"
    "Phenylalanine"
    "Threonine"
    "Tryptophan"
    "Valine"
  ],
    text: "Amino Acids"
    color: Styles.colors.blue

  miscKeys = _.extend [
    "Carotene, alpha"
    "Carotene, beta"
    "Choline, total"
    "Cryptoxanthin, beta"
    "Lutein + zeaxanthin"
    "Lycopene"
    "Phytosterols"
    "Theobromine"
  ],
    text: "Misc"
    color: Styles.colors.yellow

  sugarKeys = _.extend [
    "Fructose"
    "Galactose"
    "Glucose (dextrose)"
    "Lactose"
    "Maltose"
    "Sucrose"
    "Sugars, total"
  ],
    text: "Sugars"
    color: Styles.colors.red

  nutrientKeys = _.union(fiberKeys, vitaminKeys, mineralKeys, aminoAcidKeys, miscKeys, sugarKeys)

  unusedKeys = _.difference(allKeys, macronutrientKeys, nutrientKeys)

  onLoadCbs = []

  FoodData = {
    loaded: false
    foods: null
    nutrients: null
    foodGroups: []
    selectedFoods: []
    
    macronutrientKeys

    nutrientKeys
    fiberKeys
    vitaminKeys
    mineralKeys
    aminoAcidKeys
    miscKeys
    sugarKeys

    unusedKeys

    findNutrientById: (Nutr_No) -> _.find(@nutrients, (n) -> n.Nutr_No is Nutr_No)

    findFoodById: (id) -> _.find(allFoods, (f) -> f.NDB_No is id)
    findFoodsById: (ids) -> @findFoodById id for id in ids

    # Uses a JS click event because anchors in svgs don't play nicely with every browser.
    getNutrientJSLink: (NutrDesc) ->
      "javascript: window.location = '#{@getNutrientLink(NutrDesc)}';"

    getNutrientLink: (NutrDesc) ->
      "#/nutrients?nutrient=#{@nutrients[NutrDesc].Nutr_No}"

    # Updates `foods` to contain only the enabled `foodGroups`
    updateFoodGroups: ->
      enabledFoodGroups = _.pluck(_.filter(@foodGroups, (g) -> g.enabled), "name")
      @foods = _.filter(allFoods, (f) -> _.contains(enabledFoodGroups, f.FdGrp_Desc))

    areAllFoodGroupsEnabled: (foodGroups = FoodData.foodGroups) -> !_.find(foodGroups, (g) -> !g.enabled)
    getFoodGroupsEnabledCount: (foodGroups = FoodData.foodGroups) -> _.filter(foodGroups, (g) -> g.enabled).length

    # Mutates `foods` with compared values
    calculateRelativeValues: (foods) ->
      for key in comparedKeys
        comparedKey = key + "_Compared"
        max = _.max(foods, (f) -> f[key])[key]
        for food in foods
          if food[key]?
            food[comparedKey] = food[key] / max or 0
      foods

    # Callbacks to execute once data is loaded.
    onLoad: (cb, callIfLoaded = false) -> 
      if !@loaded
        onLoadCbs.push cb
      else if callIfLoaded
        cb()

    # Helper function for proper 2-way routing with asynchronously loaded data.
    # scope is needed because we're going outside of Angular to load data. (replace with $http promises?)
    afterLoading: (scope, cb) ->
      if @loaded
        cb()
      else
        @onLoad ->
          cb()
          scope.$apply()
  }

  loadCsvData = (path, cb) ->
    console.log "Loading .csv: ", path
    d3.csv path, (err, data) ->
      console.error err if err
      cb data

  # Convert array of nutrients to objected keyed by nutrient name
  processNutrients = (rawNutrients) ->
    data = {}
    for item in rawNutrients
      data[item.NutrDesc] = item
      item.text = keyAliases[item.NutrDesc] or item.NutrDesc
    data

  # Prepare food data using the formula nutrients/calories
  processFoods = (rawFoods) ->
    for item in rawFoods

      # Parse strings to numbers and clean up empty values
      for k, v of item
        if _.contains(comparedKeys, k)
          if v
            item[k] = parseFloat(v)
          else
            delete item[k]

      # Convert nutrients/100g to nutrients/calorie by dividing by calories/100g
      calorieKey = "Energy"
      ignoredKeys = [calorieKey, "Energy (kj)", "Total lipid (fat)", "Protein", "Carbohydrate, by difference"] # TODO TODO TODOOOOOOOOOOO
      calories = item[calorieKey]
      for k, v of item
        if typeof v is "number" and not _.contains(ignoredKeys, k)
          if calories
            item[k] = v / calories
          else
            item[k] = -v # water...

      # Convert fat, protein, carbohydrate, and alcohol to percentages of the whole
      calculatedCalorieKey = "Calories, calculated"
      fatKey = "Total lipid (fat)"
      proteinKey = "Protein"
      carbohydrateKey = "Carbohydrate, by difference"
      alcoholKey = "Alcohol, ethyl"
      item[fatKey] or= 0
      item[proteinKey] or= 0
      item[carbohydrateKey] or= 0
      item[alcoholKey] or= 0
      item[fatKey] *= 9
      item[proteinKey] *= 4
      item[carbohydrateKey] *= 4
      item[alcoholKey] *= 7
      item[calculatedCalorieKey] = item[fatKey] + item[proteinKey] + item[carbohydrateKey] + item[alcoholKey]
      item[fatKey] /= item[calculatedCalorieKey]
      item[proteinKey] /= item[calculatedCalorieKey]
      item[carbohydrateKey] /= item[calculatedCalorieKey]
      item[alcoholKey] /= item[calculatedCalorieKey]
      
    rawFoods

  setFoodGroups = (foods) ->
    foodGroups = []
    for food, i in foods
      if !_.find(foodGroups, (g) -> g.name is food.FdGrp_Desc)
        foodGroups.push 
          name: food.FdGrp_Desc
          id: "food-group-#{i}"
          enabled: true
    for group in foodGroups
      group.count = _.filter(foods, (f) -> f.FdGrp_Desc is group.name).length
    FoodData.foodGroups = foodGroups
  
  # Asynchronously load the data
  loadCsvData "data/nutrients.csv", (rawNutrients) ->
    FoodData.nutrients = processNutrients(rawNutrients)

    loadCsvData "data/foods.csv", (rawFoods) ->
      FoodData.foods = allFoods = processFoods(rawFoods)

      setFoodGroups FoodData.foods

      FoodData.loaded = true

      # Refresh once loaded
      $rootScope.$apply()
      console.log "Loaded FoodData", FoodData

      # Tell the rest of the app to refresh
      cb() for cb in onLoadCbs
      onLoadCbs = null

  FoodData