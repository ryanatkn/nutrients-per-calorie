# Adds dropdown functionality to an element.
# Performs no transclusion - you must manually call `toggle` from a child element.
# CSS requires children with the classes `dropdown-toggle` and `dropdown-content`.
module.exports = (FoodData) ->
  restrict: "C"
  link: (scope, element, attrs) ->

    onClick = (e) ->
      if element.hasClass("open") and element isnt e.target and !element.find(e.target).length
        scope.toggle()
      true

    FoodData.afterLoading scope, ->
      $(window).on "click", onClick

    scope.toggle = ->
      element.toggleClass "open"

    scope.$on "$destroy", ->
      $(window).off "click", onClick