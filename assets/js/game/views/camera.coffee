deps = ["use!use/jquery", "use!use/Three", "use!use/tween",
  "cs!../view", "cs!../resource"]
define deps,
  ($, THREE, TWEEN, view, resource) ->
    console.log TWEEN
    class Camera extends view.View
      initialize: (@camera) ->
        @velocity = [0, 0]
        @resolve()

      position: (position=null) ->
        if position isnt null
          @camera.position.x = position.x
          @camera.position.y = position.y
          return this
        else
          return @camera.position

      scrollTo: (target, speed=500) ->
        position = $.extend {}, @camera.position
        tween = new TWEEN.Tween(position).to(target, speed)
        tween.onUpdate =>
          @camera.position.x = position.x
          @camera.position.y = position.y
        tween.start()
        return tween

    return { Camera: Camera }