module.exports = ($scope, $location, FoodData, ComparePage, NutrientsPage) ->
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