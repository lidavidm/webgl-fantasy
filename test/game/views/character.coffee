deps = ["use!use/jquery", "use!use/Three", "use!use/backbone",
  "cs!../resource", "cs!../sprite-animation"]
define deps, ($, THREE, Backbone, resource, animation) ->
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
      @animation.addGroup "test", [0, 0], [1, 0]
      @animation.switchGroup "test"
      @skip = 30

    update: =>
      @skip -= 1
      if @skip <= 0
        @skip = 30
        @animation.next()

  return { Character: Character }