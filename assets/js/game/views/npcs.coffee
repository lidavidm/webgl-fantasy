deps = ["use!use/jquery", "use!use/Three", "cs!../view", "use!use/underscore",
  "cs!../resource", "cs!../sprite-animation"]
define deps, ($, THREE, view, _, resource, animation) ->
  class NonPlayerCharacters extends view.View
    initialize: ->
      @sprites = {}
      @deferred = new $.Deferred
      @deferred.resolve()

    addSprite: (name, texture, callback) ->
      texture.done (texture) ->
        @sprites[name] = sprite = new THREE.Sprite
          map: texture.data
          useScreenCoordinates: false
          scaleByViewport: true
        sprite.scale.x = sprite.scale.y = 1 / 16
        sprite.uvScale.x = 1 / 8
        sprite.position.y = 32
        @scene.add sprite, 1

        animation = new animation.SpriteFrameAnimation sprite, texture.data, 32, 32
        animation.addGroup "up", [0, 0], [1, 0]
        animation.switchGroup "up"
        animation.addGroup "down", [2, 0], [3, 0]
        animation.addGroup "left", [4, 0], [5, 0]
        animation.addGroup "right", [6, 0], [7, 0]

        callback(sprite)
