deps = ["use!use/underscore", "use!use/backbone"]
define deps, (_, Backbone) ->
  class KeyState
    constructor: ->
      @keyState = {}
      _.extend @, Backbone.Events
  
    down: (e) ->
      oldState = @keyState[e.keyCode]
      @keyState[e.keyCode] = true

      @trigger "keydown", e.keyCode if not oldState
  
    up: (e) ->
      oldState = @keyState[e.keyCode]
      @keyState[e.keyCode] = false

      @trigger "keyup", e.keyCode if oldState

    isDown: (keyCode) ->
      @keyState[keyCode]

  _.extend KeyState, Backbone.Events  # Why does it extend constructor?

  return {
    KeyState: KeyState
  }