deps = ["use!use/jquery", "use!use/underscore", "use!use/backbone"]
define deps, ($, _, Backbone) ->
  class EventEngine
    constructor: ->
      _.extend @, Backbone.Events

  class ScriptingEngine
    constructor: (@controller) ->
      @events = new EventEngine

    loadScript: (path, callback) ->
      try
        require [path], (module) =>
          for handler of module
            @on handler, module[handler]
          callback()
      catch e
        console.log e
        callback()

    on: (event, f) ->
      @events.on event, f

    trigger: (event, args...) ->
      @events.trigger event, @controller, args...

  return {
    ScriptingEngine: ScriptingEngine
    }