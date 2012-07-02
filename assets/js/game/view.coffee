define ["use!use/backbone"], ->
  class View
    constructor: (@controller, @renderer, @scene, args...) ->
      @initialize args...

    initialize: (args...) ->

    update: ->

  class UIView extends Backbone.View

  UIView.extend View

  return {
    View: View,
    UIView: UIView
    }