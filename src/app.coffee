app = module.exports = angular.module("nutrients-per-calorie", [])

app.config ($routeProvider) ->
  $routeProvider
    .when "/compare",
      templateUrl: "src/partials/compare.html"
      controller: "CompareCtrl"
      reloadOnSearch: false
    .when "/compare/:foods",
      templateUrl: "src/partials/compare.html"
      controller: "CompareCtrl"
      reloadOnSearch: false
    .when "/nutrients",
      templateUrl: "src/partials/nutrients.html"
      controller: "NutrientsCtrl"
      reloadOnSearch: false
    .when "/nutrients/:nutrient",
      templateUrl: "src/partials/nutrients.html"
      controller: "NutrientsCtrl"
      reloadOnSearch: false
    .when "/about",
      templateUrl: "src/partials/about.html"
    .when "/options",
      templateUrl: "src/partials/options.html"
      controller: "OptionsCtrl"
    .otherwise redirectTo: "/compare"

app.controller "MainCtrl",      require('./controllers/MainCtrl.coffee')
app.controller "NutrientsCtrl", require('./controllers/NutrientsCtrl.coffee')
app.controller "CompareCtrl",   require('./controllers/CompareCtrl.coffee')
app.controller "OptionsCtrl",   require('./controllers/OptionsCtrl.coffee')

app.directive "foodComparison",  require('./directives/foodComparison.coffee')
app.directive "foodSearch",      require('./directives/foodSearch.coffee')
app.directive "nutrientList",    require('./directives/nutrientList.coffee')
app.directive "foodGroupFilter", require('./directives/foodGroupFilter.coffee')
app.directive "mmInputClearer",  require('./directives/mmInputClearer.coffee')
app.directive "mmDropdown",      require('./directives/mmDropdown.coffee')
app.directive "mmKeydown",       require('./directives/mmKeydown.coffee')

app.factory "DrawingHelpers", require('./factories/DrawingHelpers.coffee')
app.factory "FoodData",       require('./factories/FoodData.coffee')
app.factory "Presets",        require('./factories/Presets.coffee')
app.factory "Styles",         require('./factories/Styles.coffee')
app.factory "ComparePage",    require('./factories/ComparePage.coffee')
app.factory "NutrientsPage",  require('./factories/NutrientsPage.coffee')
app.factory "OptionsPage",    require('./factories/OptionsPage.coffee')

app.filter "searchFoods", require('./filters/searchFoods.coffee')
app.filter "percent",     require('./filters/percent.coffee')