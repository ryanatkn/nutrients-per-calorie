# Provides a dropdown with food group checkboxes to filter the food search.
module.exports = (FoodData) ->
  supressEnableAllChange = false

  restrict: "E"
  templateUrl: "src/partials/food-group-filter.html"
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
