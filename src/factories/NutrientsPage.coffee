module.exports = ($location, FoodData) ->
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