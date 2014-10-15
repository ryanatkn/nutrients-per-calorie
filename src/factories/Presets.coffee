module.exports = (FoodData, ComparePage) ->

  defaultPresets = [
    text: "Brown rice vs white rice"
    foods: "20037,20445"
  ,
    text: "Wheat flour vs white flour"
    foods: "20080,20481"
  ,
    text: "Vegetable protein - not just from beans!"
    foods: "11096,11090,11233,11457,11019,16043,16015,20137"
  ,
    text: "Greens and meats"
    foods: "11457,11161,11250,05009,13443"
  ,
    text: "Calcium (doesn't account for absorption!)"
    foods: "11161,11096,11457,01079,01026,01009"
  ,
    text: "Beans vs rice"
    foods: "16043,20041"
  ]

  presetSaveKey = "presets"

  savedPresets = window.localStorage.getItem(presetSaveKey)
  savedPresets = JSON.parse(savedPresets) if savedPresets

  data =
    save: -> window.localStorage.setItem(presetSaveKey, JSON.stringify(data.presets))
    create: (text) ->
      preset = 
        text: text
        foods: _.pluck(ComparePage.selectedFoods, "NDB_No").join(",")
      data.presets.unshift preset
      data.save()
    presets: savedPresets or defaultPresets
    add: (text, foods) ->
      data.presets.push {text, foods}
      data.save()
    remove: (preset) ->
      data.presets = _.without(data.presets, preset)
      data.save()
    activate: (preset) ->
      ids = preset.foods.split(",")
      foods = FoodData.findFoodsById(ids)
      ComparePage.reset foods