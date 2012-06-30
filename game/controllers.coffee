deps = ["use!use/jquery", "use!use/Three", "use!use/Stats"
  "cs!./views", "cs!./resource", "cs!./event-keystate", "cs!./collision"]
define deps, ($, THREE, Stats, views, resource, keystate, collision) ->

  WIDTH = 640
  HEIGHT = 640

  class ZScene
    constructor: (@camera, numScenes) ->
      @scenes = []
      for i in [0...numScenes]
        scene = new THREE.Scene()
        @scenes.push scene

      @scenes[0].add @camera

    add: (object, z = 0) ->
      if not @scenes[z] then throw console.error "z out of range: " + z
  
      @scenes[z].add object

    remove: (object, z) ->
      if not @scenes[z] then throw console.error "z out of range: " + z

      @scenes[z].remove object


  class Controller
    constructor: ->
      @camera = new THREE.OrthographicCamera -WIDTH / 2, WIDTH / 2, HEIGHT /
        2, -HEIGHT / 2, 0, 100

      @scene = new ZScene @camera, 3

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
      return view

    keydown: (e) => @keyState.down(e)

    keyup: (e) => @keyState.up(e)

    draw: ->
      @renderer.clear()
      for scene in @scene.scenes
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

      accumulator += frameTime
      while accumulator >= 33
        @update()
        accumulator -= 33

      @draw()

      @stats.end()

      window.webkitRequestAnimationFrame =>  # TODO: requestAnimationFrame shim!
        @animate newTime, accumulator

    transition: (controller) ->
      # Transition to a different controller within 1 frame
      @animate = ->
        controller.animate()
      $(@renderer.domElement).remove()
      $(@stats.domElement).remove()


  class Title extends Controller
    constructor: ->
      super()

      @ui = @addView views.TitleUI, $("#ui"), Overworld
          

  class Overworld extends Controller
    constructor: ->
      super()

      @tilemap = @addView(views.Tilemap,
        resource.loadJSON ("res/test2.json?t="+(new Date).getTime()))
      @character = @addView views.Character, resource.loadTexture "res/fighter.png"
      @cameraView = @addView views.Camera, @camera

      @texture = THREE.ImageUtils.loadTexture "res/fighter.png", undefined, =>
        @characterView = new views.Character @, @renderer, @scene,
          new resource.Resource "res/", @texture

      @collision = new collision.CollisionManager
      
      @ui = @addView views.WorldUI, $("#ui")

  return {
    Title: Title,
    Overworld: Overworld
  }