# Provides a selectable list of nutrients.
module.exports = (FoodData) ->
  restrict: "E"
  templateUrl: "src/partials/nutrient-list.html"
  scope:
    nutrientKeys: "="
    helpers: "="
  link: (scope, element, attrs) ->
    scope.nutrients = _.map(scope.nutrientKeys, (n) -> FoodData.nutrients[n])