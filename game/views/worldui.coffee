deps = ["use!use/jquery", "cs!../view", "use!use/underscore",
  "cs!../resource"]
define deps, ($, view, _, resource) ->
  class WorldUI extends view.View
    initialize: (controller, renderer, scene, el) ->
      @el = $(el)
      @el.css {
        width: 320,
        height: 320,
        display: "block",
        position: "absolute",
        left: 0,
        top: 0,
        color: "#FFFFFF",
        fontFamily: "Cantarell"
        }
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