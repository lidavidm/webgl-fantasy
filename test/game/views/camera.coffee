define ["use!use/jquery", "use!use/Three", "use!use/backbone", "cs!../resource"],
  ($, THREE, Backbone, resource) ->
    class Camera extends Backbone.View
      initialize: (@renderer, @scene, @camera) ->
        @setElement @renderer.domElement
        super()
        $(document.body).keydown(@keydown)
        $(document.body).keyup(@keyup)
        @velocity = [0, 0]

      keydown: (e) =>
        @velocity = [0, 0]
        switch e.keyCode
          when 38 then @velocity[1] = -0.25
          when 40 then @velocity[1] = 0.25
          when 37 then @velocity[0] = -0.25
          when 39 then @velocity[0] = 0.25

      keyup: (e) =>
        switch e.keyCode
          when 38 then @velocity[1] = 0
          when 40 then @velocity[1] = 0
          when 37 then @velocity[0] = 0
          when 39 then @velocity[0] = 0
  
      update: =>
        @camera.position.x += @velocity[0]
        @camera.position.y += @velocity[1]
        console.log(@velocity)

    return { Camera: Camera }