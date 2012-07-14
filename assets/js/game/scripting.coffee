deps = ["use!use/jquery", "use!use/underscore", "use!use/backbone"]
define deps, ($, _, Backbone) ->
  class EventEngine
    constructor: ->
      _.extend @, Backbone.Events

  class ScriptingEngine
    constructor: (@controller) ->
      @events = new EventEngine
      @needToClear = {}

    loadScript: (path, callback) ->
      try
        require [path], (module) =>
          for handler of module
            @on handler, module[handler]
            if not @needToClear[handler]?
              @needToClear[handler] = []
            if not module[handler].global? or not module[handler].global
              @needToClear[handler].push module[handler]
          callback()
      catch e
        console.log e
        callback()

    on: (event, f) ->
      @events.on event, f

    off: (event, f) ->
      @events.off event, f

    clear: ->
      for event of @needToClear
        for handler in @needToClear[event]
          @off event, handler
      @needToClear = {}

    trigger: (event, args...) ->
      @events.trigger event, @controller, args...

  return {
    ScriptingEngine: ScriptingEngine
    }