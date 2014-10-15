module.exports = ($location, FoodData) ->
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