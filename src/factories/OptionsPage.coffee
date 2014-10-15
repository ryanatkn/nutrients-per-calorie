module.exports = (FoodData) ->
  data =
    setActiveDatabase: (database) ->
      if FoodData.databases.getActive() isnt database
        FoodData.databases.setActive database
    getActiveDatabase: -> FoodData.databases.getActive().name