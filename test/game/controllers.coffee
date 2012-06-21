deps = ["use!use/jquery", "use!use/Three", "use!use/Stats"
  "cs!./views", "cs!./resource", "cs!./event-keystate"]
define deps, ($, THREE, Stats, views, resource, keystate) ->

  WIDTH = 320
  HEIGHT = 320

  FPS = 30
  MAX_FRAME_SKIP = 10
  SKIP_TICKS = 1000 / FPS

  class ZScene
    constructor: (@camera, numScenes) ->
      @scenes = []
      for i in [0...numScenes]
        @scenes.push new THREE.Scene()

      @scenes[numScenes - 1].add @camera

    add: (object, z = 0) ->
      if not @scenes[z] then throw console.error "z out of range: " + z
  
      @scenes[z].add object


  class Controller
    constructor: ->
      @camera = new THREE.OrthographicCamera -WIDTH / 2, WIDTH / 2, HEIGHT /
        2, -HEIGHT / 2, 0, 100

      @scene = new ZScene @camera, 4

      @renderer = new THREE.WebGLRenderer { antialias: true }
      @renderer.setSize WIDTH, HEIGHT
      @renderer.setClearColorHex 0x000000, 1
      @renderer.autoClear = false
      $(document.body).append @renderer.domElement

      @stats = new Stats
      @stats.setMode 0
      @stats.domElement.style.position = 'absolute'
      @stats.domElement.style.left = '0px'
      @stats.domElement.style.top = '320px'
      $(document.body).append @stats.domElement

      @keyState = new keystate.KeyState
      $(document.body).keydown @keydown
      $(document.body).keyup @keyup

      @loading = []
      @views = []

    addView: (klass, args...) ->
      view = new klass @, @renderer, @scene, args...
      @loading.push view.deferred
      @views.push view

    keydown: (e) => @keyState.down(e)

    keyup: (e) => @keyState.up(e)

    draw: ->
      @renderer.clear()
      scenes = []
      for scene in @scene.scenes
        if scene?
          scenes.push scene
      for scene in scenes.reverse()
        @renderer.render scene, @camera

    update: ->
      for view in @views
        view.update()

    animate: (currentTime = (new Date).getTime(), accumulator = 0) =>
      @stats.begin()
      # based on http://gafferongames.com/game-physics/fix-your-timestep/
      newTime = (new Date).getTime()
      frameTime = newTime - currentTime

      if (frameTime > 250) then frameTime = 250

      dt = 33

      accumulator += frameTime
      while accumulator >= dt
        @update()
        accumulator -= dt

      @draw()

      @stats.end()

      window.webkitRequestAnimationFrame =>  # TODO: requestAnimationFrame shim!
        this.animate newTime, accumulator
          

  class App extends Controller
    constructor: ->
      super()

      @addView views.Tilemap, resource.loadJSON "res/test2.json"
      @addView views.Character, resource.loadTexture "res/fighter.png"
      @addView views.Camera, @camera

      @texture = THREE.ImageUtils.loadTexture "res/fighter.png", undefined, =>
        @characterView = new views.Character @, @renderer, @scene,
          new resource.Resource "res/", @texture
        @loading[1].resolve()

  return {
    App: App
  }