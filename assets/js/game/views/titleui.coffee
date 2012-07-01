deps = ["use!use/jquery", "cs!../view", "use!use/underscore",
  "cs!../resource"]
define deps, ($, view, _, resource) ->
  class TitleUI extends view.View
    initialize: (controller, renderer, scene, el, @klassOverworld) ->
      @el = $(el)
      @elOverlay = $("<div>Title Screen</div>").appendTo(@el).css {
        textAlign: "center",
        width: "100%",
        marginTop: "40px",
        fontSize: "20px"
        }

      @counter = 10

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