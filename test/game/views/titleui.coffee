deps = ["use!use/jquery", "use!use/backbone", "use!use/underscore",
  "cs!../resource"]
define deps, ($, Backbone, _, resource) ->
  class TitleUI extends Backbone.View
    initialize: (@controller, @renderer, @scene, el, @klassOverworld) ->
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
      @elOverlay = $("<div>Title Screen</div>").appendTo(@el).css {
        textAlign: "center",
        width: "100%",
        marginTop: "40px",
        fontSize: "20px"
        }

      @counter = 50

    update: ->
      @counter -= 1
      if @counter is 0
        @el.html ""
        overworld = new @klassOverworld
        $.when(overworld.loading...).then =>
          @controller.transition overworld

  return {
    TitleUI: TitleUI
    }