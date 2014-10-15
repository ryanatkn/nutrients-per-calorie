# Evalulates `mm-keydown` when one of the space-separated `mm-key-codes` are pressed.
module.exports = ->
  link: (scope, element, attrs) ->
    element.on "keydown", (e) ->
      if _.contains(attrs.mmKeyCodes.split(" "), e.keyCode.toString())
        scope.$apply ->
          scope.$eval attrs.mmKeydown
      true