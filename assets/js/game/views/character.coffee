deps = ["use!use/jquery", "use!use/Three", "cs!../view", "use!use/underscore",
  "cs!../resource", "cs!../sprite-animation"]
define deps, ($, THREE, view, _, resource, animation) ->
  class Character extends view.View
    initialize: ->
      @width = 32
      @height = 32

      resource.loadSpriteModel(@model.get('sprite').world)
        .done(@initializeWorldSprite)

      resource.loadSpriteModel(@model.get('sprite').battle)
        .done(@initializeBattleSprite)

      @teleporting = false

    initializeWorldSprite: (@sprite, @animation) =>
      @scene.add @sprite, 1
      @animation.switchGroup "up"
      @skip = 0
      @velocity = [0, 0]

      @controller.keyState.on "keydown", (keyCode) =>
        collision = @controller.collision.collidesDirections {
          x: @sprite.position.x + 2, y: @sprite.position.y + 2,
          height: @height, width: @width }
        switch keyCode
          when 38
            if collision.y isnt -1
              @animation.switchGroup "up"
              @velocity[1] = 2
          when 40
            if collision.y isnt 1
              @animation.switchGroup "down"
              @velocity[1] = -2
          when 37
            if collision.x isnt 1
              @animation.switchGroup "left"
              @velocity[0] = -2
          when 39
            if collision.x isnt -1
              @animation.switchGroup "right"
              @velocity[0] = 2
          when 32
            if @teleport? and not @teleporting
              @controller.tilemap.changeTo(
                resource.loadJSON(@teleport + ".json?t="+((new Date).getTime()))
                )
              @teleporting = true
          when 65
            activatable = @controller.activatable.faces {
              x: @sprite.position.x
              y: @sprite.position.y
              height: @height
              width: @width
              },
              'x', 1, 1
            console.log activatable
        if @velocity[0] or @velocity[1]
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

      @controller.tilemap.deferred.done @setSpritePosition

    initializeBattleSprite: (@battleSprite, @battleAnimation) =>
      @scene.add @battleSprite, 2
      @battleAnimation.switchGroup "up"
      @battleSprite.scale.x = @battleSprite.scale.y = 1 / 4

    setSpritePosition:  =>
      properties = @controller.tilemap.properties
      @teleporting = false  # XXX shouldn’t this be in controller or something?

      mapType = 'world'
      if properties.type?
        mapType = properties.type

      if mapType is 'world'
        @width = 16
        @height = 16
        @sprite.scale.x = @sprite.scale.y = 1 / 8
      else
        @width = 20
        @height = 20
        @sprite.scale.x = @sprite.scale.y = 1 / 4
      x = 0
      y = 0
      if properties.start?
        [x, y] = properties.start.split ","
        x = parseInt x
        y = parseInt y
      pixelWidth = @controller.tilemap.width * @controller.tilemap.tileWidth
      pixelHeight = @controller.tilemap.height * @controller.tilemap.tileHeight
      @sprite.position.x = x * @controller.tilemap.tileWidth
      @sprite.position.y = y * @controller.tilemap.tileHeight
      @sprite.position.x -= (pixelWidth / 2) - (@width / 2)
      @sprite.position.y -= (pixelHeight / 2) - (@height / 2)
      @sprite.position.y *= -1
      @controller.cameraView.position @sprite.position

      @controller.scripting.trigger "entered"
      @resolve()

    update: =>
      if @moving
        @sprite.position.x += @velocity[0]
        @sprite.position.y += @velocity[1]
        @controller.cameraView.position @sprite.position
        collision = @controller.collision.collidesDirections {
          x: @sprite.position.x + 2, y: @sprite.position.y + 2,
          height: @height, width: @width }
        @velocity[0] = 0 if collision.x * @velocity[0] < 0
        @velocity[1] = 0 if collision.y * @velocity[1] < 0
        if collision.teleport?
          @controller.ui.overlay collision.teleport
          @teleport = collision.teleport
        else
          @controller.ui.clearOverlay()
          @teleport = null

        if @velocity[0] is 0 and @velocity[1] is 0
          @moving = false
          return

        @skip -= 1
        if @skip <= 0
          @skip = 6
          @animation.next()

  return { Character: Character }