define ["use!use/backbone"], ->
  class View
    constructor: (@controller, @renderer, @scene, @model, args...) ->
      @initialize args...

    initialize: (args...) ->

    update: ->

  class UIView extends View

  return {
    View: View,
    UIView: UIView
    }