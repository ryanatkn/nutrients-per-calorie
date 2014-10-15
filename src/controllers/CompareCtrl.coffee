module.exports = ($scope, $routeParams, $timeout, FoodData, ComparePage, Presets) ->
  
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