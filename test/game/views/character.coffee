deps = ["use!use/jquery", "use!use/Three", "use!use/backbone", "use!use/underscore",
  "cs!../resource", "cs!../sprite-animation", "cs!../event-keystate"]
define deps, ($, THREE, Backbone, _, resource, animation, keystate) ->
  class Character extends Backbone.View
    constructor: (@renderer, @scene, sprite) ->
      @setElement @renderer.domElement
      super()

      @width = 32
      @height = 32

      texture = sprite.data
      console.log texture.image

      @sprite = new THREE.Sprite
        map: texture
        useScreenCoordinates: true
      @sprite.position.set(100, 100, 0)
      @sprite.scale.x = @sprite.scale.y = 1 / 8
      @sprite.uvScale.x = 1 / 8
      @sprite.uvOffset.x = 1/ 8
      @scene.add @sprite

      @animation = new animation.SpriteFrameAnimation @sprite, texture, 32, 32
      @animation.addGroup "up", [0, 0], [1, 0]
      @animation.switchGroup "up"
      @animation.addGroup "down", [2, 0], [3, 0]
      @animation.addGroup "left", [4, 0], [5, 0]
      @animation.addGroup "right", [6, 0], [7, 0]
      @skip = 0
  
      $(document.body).keydown @keydown
      $(document.body).keyup @keyup
      @velocity = [0, 0]

      @keyState = new keystate.KeyState
      @keyState.on "keydown", (keyCode) =>
        switch keyCode
          when 38 then @animation.switchGroup "up"
          when 40 then @animation.switchGroup "down"
          when 37 then @animation.switchGroup "left"
          when 39 then @animation.switchGroup "right"
        if 37 <= keyCode <= 40
          @moving = true
          @skip = 0

      @keyState.on "keyup", (keyCode) =>
        if 37 <= keyCode <= 40
          states = (@keyState.isDown key for key in [37..40])
          console.log(states, _.any(states))
          if not (_.any(@keyState.isDown key for key in [37..40]))
            console.log "stop"
            @moving = false

      @moving = false

    keydown: (e) => @keyState.down(e)

    keyup: (e) => @keyState.up(e)

    update: =>
      if @moving
        @skip -= 1
        if @skip <= 0
          @skip = 6
          @animation.next()

  return { Character: Character }