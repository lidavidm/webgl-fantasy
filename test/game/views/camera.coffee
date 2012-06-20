define ["use!use/jquery", "use!use/Three", "use!use/backbone", "cs!../resource"],
  ($, THREE, Backbone, resource) ->
    class Camera extends Backbone.View
      initialize: (@controller, @renderer, @scene, @camera) ->
        @setElement @renderer.domElement
        @velocity = [0, 0]

      setPosition: (position) ->
        @camera.position.x = position.x
        @camera.position.y = position.y
  
      update: =>

    return { Camera: Camera }