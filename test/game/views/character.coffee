define ["use!use/jquery", "use!use/Three", "use!use/backbone", "cs!../resource"],
  ($, THREE, Backbone, resource) ->
    class Character extends Backbone.View
      initialize: (@renderer, @scene) ->
        @setElement @renderer.domElement
        super()

      update: =>

    return { Character: Character }