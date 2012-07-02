define ["use!use/jquery", "use!use/Three", "cs!../view", "cs!../resource"],
  ($, THREE, view, resource) ->
    class Camera extends view.View
      initialize: (@camera) ->
        @velocity = [0, 0]

      setPosition: (position) ->
        @camera.position.x = position.x
        @camera.position.y = position.y
  
      update: =>

    return { Camera: Camera }