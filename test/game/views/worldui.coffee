deps = ["use!use/jquery", "use!use/backbone", "use!use/underscore",
  "cs!../resource"]
define deps, ($, Backbone, _, resource) ->
  class WorldUI extends Backbone.View
    initialize: (@controller, @renderer, @scene, el) ->
      @setElement el
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