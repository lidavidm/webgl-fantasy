Game = {
  Models: {},
  Controllers: {}
  Views: {}
}

WIDTH = 320
HEIGHT = 320

FPS = 30
MAX_FRAME_SKIP = 10
SKIP_TICKS = 1000 / FPS

Game.Controllers.App = class
  constructor: ->
    @camera = new THREE.OrthographicCamera -WIDTH / 2, WIDTH / 2, -HEIGHT /
      2, HEIGHT / 2, 0, 100

    @scene = new THREE.Scene
    @scene.add @camera

    @renderer = new THREE.WebGLRenderer { antialias: true }
    @renderer.setSize WIDTH, HEIGHT
    @renderer.setClearColorHex 0x000000, 1
    $(document.body).append @renderer.domElement

    @appView = new Game.Views.App @renderer, @scene

    @nextGameTick = (new Date).getTime()

  draw: ->
    @renderer.render this.scene, this.camera

  update: ->
    @appView.update()

  animate: =>
    # Based on https://github.com/jsermeno/ballGame/blob/master/public/js/controllers/appController.js
    loops = 0

    while (new Date).getTime() > @nextGameTick and loops < MAX_FRAME_SKIP
      @update()
      nextGameTick += SKIP_TICKS
      loops++

    if loops == MAX_FRAME_SKIP
      nextGameTick = (new Date).getTime()


    @draw()
    window.webkitRequestAnimationFrame this.animate  # TODO: rAF shim!

Game.Views.App = class extends Backbone.View
  events: {}

  initialize: (@renderer, @scene) ->
    @initializeMap()

  update: =>

  initializeMap: ->
    grass = THREE.ImageUtils.loadTexture "grass.png"
    grass.wrapT = grass.wrapS = THREE.RepeatWrapping

    water = THREE.ImageUtils.loadTexture "water.png"
    water.wrapT = water.wrapS = THREE.RepeatWrapping

    ts = THREE.ImageUtils.loadTexture "ts.png"

    grassT = [
      new THREE.UV(0, 0),
      new THREE.UV(0, 1),
      new THREE.UV(0.5, 1),
      new THREE.UV(0.5, 0)
    ]

    waterT =  [
      new THREE.UV(0.5, 0),
      new THREE.UV(0.5, 1),
      new THREE.UV(1, 1),
      new THREE.UV(1, 0)
    ]

    tiles = 2
    size = 32

    plane = new THREE.PlaneGeometry tiles * size, tiles * size, tiles, tiles

    plane.materials[0] = new THREE.MeshBasicMaterial { map: ts }
    plane.materials[1] = new THREE.MeshBasicMaterial { map: ts }

    for uvs in plane.faceVertexUvs
      for j in [0...uvs.length]
        console.log uvs[j], grassT
        uvs[j] = grassT
        # for uv in uvs[j]
        #   console.log uv.u, uv.v
        #   uv.u *= tiles
        #   uv.v *= tiles
        #   uv.u /= 2
        # console.log('---', uvs[j].length)


    counter = 0
    for face in plane.faces
      face.materialIndex = counter
      counter = if counter is 0 then 1 else 0

    mesh = new THREE.Mesh plane, new THREE.MeshFaceMaterial
    mesh.rotation.x = -Math.PI / 2

    @scene.add(mesh)

$(document).ready ->
  app = new Game.Controllers.App
  app.animate()
