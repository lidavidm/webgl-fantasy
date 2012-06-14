deps = ["use!use/jquery", "use!use/Three", "use!use/backbone", "cs!../resource"]
define deps, ($, THREE, Backbone, resource) ->
  class Character extends Backbone.View
    initialize: (@renderer, @scene, sprite) ->
      @setElement @renderer.domElement
      super()

      @width = 32
      @height = 32
      console.log sprite.data

      texture = sprite.data

      @sprite = new THREE.Sprite
        map: texture
        useScreenCoordinates: true
      @sprite.position.set(100, 100, 0)
      @sprite.scale.x = @sprite.scale.y = 1 / 8
      @sprite.uvScale.x = 1 / 8
      @sprite.uvOffset.x = 1/ 4
      @scene.add @sprite

      @mod = 0
      @skip = 30

    update: =>
      @skip -= 1
      if @skip is 0
        @skip = 30
        @mod = (@mod + 1) % 8
        @sprite.uvOffset.x = @mod / 8

  return { Character: Character }