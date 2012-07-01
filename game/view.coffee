define ["use!use/backbone"], ->
  class View
    constructor: (@controller, @renderer, @scene, el, args...) ->
      @initialize controller, renderer, scene, el, args...

    initialize: (controller, renderer, scene, el, args...) ->

    update: ->

  class UIView extends Backbone.View

  UIView.extend View

  return {
    View: View,
    UIView: UIView
    }