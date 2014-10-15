# Provides a search box and food list from which foods can be selected.
module.exports = ->
  restrict: "E"
  templateUrl: "src/partials/food-search.html"
  scope:
    foodData: "="
    helpers: "="