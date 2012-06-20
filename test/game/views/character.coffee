deps = ["use!use/jquery", "use!use/Three", "use!use/backbone", "use!use/underscore",
  "cs!../resource", "cs!../sprite-animation"]
define deps, ($, THREE, Backbone, _, resource, animation) ->
  class Character extends Backbone.View
    initialize: (@controller, @renderer, @scene, sprite) ->
      @setElement @renderer.domElement

      @width = 32
      @height = 32

      texture = sprite.data
      console.log texture.image

      @sprite = new THREE.Sprite
        map: texture
        useScreenCoordinates: false
        scaleByViewport: true
      @sprite.scale.x = @sprite.scale.y = 1 / 8
      @sprite.uvScale.x = 1 / 8
      @scene.add @sprite

      @animation = new animation.SpriteFrameAnimation @sprite, texture, 32, 32
      @animation.addGroup "up", [0, 0], [1, 0]
      @animation.switchGroup "up"
      @animation.addGroup "down", [2, 0], [3, 0]
      @animation.addGroup "left", [4, 0], [5, 0]
      @animation.addGroup "right", [6, 0], [7, 0]
      @skip = 0
      @velocity = [0, 0]
  
      @controller.keyState.on "keydown", (keyCode) =>
        switch keyCode
          when 38
            @animation.switchGroup "up"
            @velocity[1] = -1
          when 40
            @animation.switchGroup "down"
            @velocity[1] = 1
          when 37
            @animation.switchGroup "left"
            @velocity[0] = -1
          when 39
            @animation.switchGroup "right"
            @velocity[0] = 1
        if 37 <= keyCode <= 40
          @moving = true
          @skip = 0

      @controller.keyState.on "keyup", (keyCode) =>
        if 37 <= keyCode <= 40
          if keyCode is 37 or keyCode is 39 then @velocity[0] = 0
          if keyCode is 38 or keyCode is 40 then @velocity[1] = 0
          states = (@controller.keyState.isDown key for key in [37..40])
          if not (_.any(@controller.keyState.isDown key for key in [37..40]))
            @moving = false

      @moving = false

    update: =>
      if @moving
        @sprite.position.x += @velocity[0]
        @sprite.position.y += @velocity[1]
        @controller.cameraView.setPosition @sprite.position
        @skip -= 1
        if @skip <= 0
          @skip = 6
          @animation.next()

  return { Character: Character }