deps = ["use!use/jquery", "cs!../view", "use!use/underscore",
  "cs!../resource"]
define deps, ($, view, _, resource) ->
  class WorldUI extends view.UIView
    initialize: (el, args...) ->
      @el = $(el)
      @elOverlay = $("<div></div>").appendTo(@el).css { textAlign: 'center' }

    update: ->
    overlay: (text) ->
      @elOverlay.html text

    clearOverlay: ->
      @elOverlay.html ""

    characterOverlay: ->

  return {
    WorldUI: WorldUI
    }