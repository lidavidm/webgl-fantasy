define ["use!use/jquery", "use!use/backbone"], ($) ->
  class View
    constructor: (@controller, @renderer, @scene, @model, args...) ->
      @pipeline = []
      @deferred = new $.Deferred
      @initialize args...

    initialize: (args...) ->

    update: ->

    resolve: ->
      if @pipeline.length > 0
        $.when(@pipeline...).done =>
          @deferred.resolve()
          @pipeline = []
      else
        @deferred.resolve()

    defer: (deferred) ->
      @pipeline.push deferred


  class UIView extends Backbone.View

  return {
    View: View,
    UIView: UIView
    }