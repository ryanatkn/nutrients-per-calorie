# Adds an X to text input fields for quick clearing.
module.exports = ->
  link: (scope, element, attrs) ->
    inputClearer = angular.element("<div class='input-clearer'>✕</div>")
    inputClearer.on "click", ->
      element.val("").focus().trigger("input") # the trigger is needed to tell angular to sync the input's model :/
    element.after inputClearer