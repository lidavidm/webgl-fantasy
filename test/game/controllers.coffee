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

      @cameraView = new views.Camera @renderer, @scene, @camera

      @nextGameTick = (new Date).getTime()

    draw: ->
      @renderer.render this.scene, this.camera

    update: ->
      @appView.update()
      @cameraView.update()

    animate: (currentTime = (new Date).getTime(), accumulator = 0) =>
      # based on http://gafferongames.com/game-physics/fix-your-timestep/
      newTime = (new Date).getTime()
      frameTime = newTime - currentTime

      if (frameTime > 250) then frameTime = 250

      accumulator += frameTime

      while accumulator >= 10
        @update()
        t += 10
        accumulator -= 10

      @draw()

      window.webkitRequestAnimationFrame =>  # TODO: requestAnimationFrame shim!
        this.animate currentTime, accumulator

      

  return {
    App: App
  }