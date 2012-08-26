deps = ["use!use/jquery", "use!use/Three", "cs!../view",
  "cs!../sprite-animation"]
define deps, ($, THREE, view, animation) ->
  class NonPlayerCharacters extends view.View
    initialize: (args...) ->
      @sprites = {}
      @resolve()

    addSprite: (name, texture, callback=->) ->
      texture.done =>
        @sprites[name] = sprite = new THREE.Sprite
          map: texture.data
          useScreenCoordinates: false
          scaleByViewport: true
        sprite.scale.x = sprite.scale.y = 1 / 4
        sprite.uvScale.x = 1 / 8
        @scene.add sprite, 1

        anim = new animation.SpriteFrameAnimation sprite, texture.data, 32, 32
        anim.addGroup "up", [0, 0], [1, 0]
        anim.addGroup "down", [2, 0], [3, 0]
        anim.addGroup "left", [4, 0], [5, 0]
        anim.addGroup "right", [6, 0], [7, 0]
        callback(sprite, anim)

    clear: ->
      @scene.remove @sprites[sprite], 1 for sprite of @sprites

      @sprites = {}

  return {
    NonPlayerCharacters: NonPlayerCharacters
    }
