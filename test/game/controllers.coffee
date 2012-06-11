deps = ["use!use/jquery", "use!use/Three", "cs!./views", "cs!./resource"]
define deps, ($, THREE, views, resource) ->

  WIDTH = 320
  HEIGHT = 320

  FPS = 30
  MAX_FRAME_SKIP = 10
  SKIP_TICKS = 1000 / FPS

  class App
    constructor: ->
      @camera = new THREE.OrthographicCamera -WIDTH / 2, WIDTH / 2, -HEIGHT /
        2, HEIGHT / 2, 0, 100

      @scene = new THREE.Scene
      @scene.add @camera

      @renderer = new THREE.WebGLRenderer { antialias: true }
      @renderer.setSize WIDTH, HEIGHT
      @renderer.setClearColorHex 0x000000, 1
      $(document.body).append @renderer.domElement

      @loading = new $.Deferred
  
      $.getJSON "res/test2.json", (data) =>
        @appView = new views.Tilemap @renderer, @scene,
          new resource.Resource "res/", data
        @loading.resolve()

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

  return {
    App: App
  }