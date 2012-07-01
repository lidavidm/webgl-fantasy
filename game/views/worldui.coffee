deps = ["use!use/jquery", "cs!../view", "use!use/underscore",
  "cs!../resource"]
define deps, ($, view, _, resource) ->
  class WorldUI extends view.UIView
    initialize: (controller, renderer, scene, el) ->
      @el = $(el)
      @elOverlay = $("<div>test</div>").appendTo(@el).css {
        textAlign: "center",
        width: "100%",
        marginTop: "20px"
        }

    update: ->
    overlay: (text) ->
      @elOverlay.html text

    clearOverlay: ->
      @elOverlay.html ""

  return {
    WorldUI: WorldUI
    }