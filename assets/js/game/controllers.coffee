deps = ["use!use/jquery", "use!use/Three", "use!use/Stats"
  "cs!./views", "cs!./resource", "cs!./event-keystate", "cs!./collision",
  "cs!./models", "cs!./data", "cs!./scripting"]
define deps, ($, THREE, Stats, views, resource, keystate, collision, models,
  data, scripting) ->

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
      @scripting = new scripting.ScriptingEngine @
      @camera = new THREE.OrthographicCamera -WIDTH / 2, WIDTH / 2, HEIGHT /
        2, -HEIGHT / 2, 0, 100

      @scene = new ZScene @camera, 3

      @renderer = new THREE.WebGLRenderer { antialias: true }
      @renderer.setSize WIDTH, HEIGHT
      @renderer.setClearColorHex 0x000000, 1
      @renderer.autoClear = false
      $(document.body).prepend @renderer.domElement

      @stats = new Stats
      @stats.setMode 0
      @stats.domElement.style.position = 'absolute'
      @stats.domElement.style.left = '0px'
      @stats.domElement.style.top = '0px'
      $(document.body).append @stats.domElement

      @keyState = new keystate.KeyState
      $(document.body).keydown @keydown
      $(document.body).keyup @keyup

      @loading = []
      @views = []
      @paused = false

      window.requestAnimationFrame = window.requestAnimationFrame ||
        window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame

    addView: (klass, model, args...) ->
      view = new klass @, @renderer, @scene, model, args...
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

    pause: (pauseViews...) ->
      if not @paused
        @oldUpdate = @update
        @paused = true
        @keyState.pause()
        @update = =>
          for view in pauseViews
            view.update()

    unpause: ->
      if @oldUpdate?
        @paused = false
        @update = @oldUpdate
        @keyState.unpause()

    animate: (currentTime = (new Date).getTime(), accumulator = 0) =>
      @stats.begin()
      # based on http://gafferongames.com/game-physics/fix-your-timestep/
      newTime = (new Date).getTime()
      frameTime = newTime - currentTime

      if (frameTime > 250) then frameTime = 250

      accumulator += frameTime
      while accumulator >= 25
        @update()
        accumulator -= 25

      @draw()

      @stats.end()

      window.requestAnimationFrame =>
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

      @ui = @addView views.TitleUI, null, $("#ui"), Overworld


  class Overworld extends Controller
    constructor: ->
      super()

      ironSword = data[data.find { name: "Iron Sword" }]

      @santi = models.Characters.create
        name: "Santiago"
        inventory: [ironSword, ironSword, ironSword, ironSword, ironSword]
      @santi.behavesAs models.Santiago

      @tilemap = @addView(views.Tilemap, null,
        resource.loadJSON ("cornelia.json?t="+(new Date).getTime()))
      @npcs = @addView(views.NonPlayerCharacters, null, null)
      @character = @addView(
        views.Character,
        @santi,
        resource.loadTexture "fighter.png"
        )
      @cameraView = @addView views.Camera, null, @camera

      @collision = new collision.CollisionManager
      @activatable = new collision.CollisionManager

      @ui = @addView views.WorldUI, null, $("#ui")

  return {
    Title: Title,
    Overworld: Overworld
  }