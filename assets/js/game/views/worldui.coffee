deps = ["use!use/jquery", "cs!../view", "use!use/underscore",
  "cs!../resource"]
define deps, ($, view, _, resource) ->

  ANIMATION_SPEED =
    FAST: 300
    SLOW: 600

  class CharacterOverlay extends view.UIView
    tagName: "div"

    template: _.template $("#templ-character-overlay").html()

    hide: ->
      $(@el).fadeOut ANIMATION_SPEED.FAST

    show: ->
      @render()
      $(@el).fadeIn ANIMATION_SPEED.FAST

    render: =>
      $(@el)
        .addClass('templ-character-overlay')
        .html(@template { data: @model.toJSON() })

      $(@el)
        .find('.statbar')
        .css({ marginRight: "2em" })

      $($(@el).find('.statbar')[0])
        .html('<div/><span>' + @model.get("stats").health + ' hp</span>')
        .children('div')
        .width(0)
        .animate {
          width: (100 *
            (@model.get("stats").health / @model.get("maxStats").health))
          },
          { duration: ANIMATION_SPEED.SLOW }
      $($(@el).find('.statbar')[1])
        .html('<div/><span>' + @model.get("stats").mana + ' mana</span>')
        .children('div')
        .width(0)
        .animate {
          width: (100 *
            (@model.get("stats").mana / @model.get("maxStats").mana))
          },
          { duration: ANIMATION_SPEED.SLOW }


  class WorldUI extends view.View
    initialize: (el, args...) ->
      @el = $(el)
      @elOverlay = $("<div></div>")
        .appendTo(@el)
        .css { textAlign: 'center', color: "#FFF" }

      @controller.keyState.on "ui_keydown", (keyCode) =>
        if keyCode is 81  # Q
          if @controller.paused
            @controller.unpause()
            @showOverlay()
            @characterOverlay.hide()
          else
            @controller.pause @
            @hideOverlay()
            @characterOverlay.show()

      @controller.character.deferred.done =>
        @characterOverlay = new CharacterOverlay {
          model: @controller.character.model }
        @el.append @characterOverlay.el

    update: ->
    overlay: (text) ->
      @elOverlay.html text

    clearOverlay: ->
      @elOverlay.html ""

    hideOverlay: ->
      @elOverlayHeight = @elOverlay.height()
      @elOverlay.animate { height: 0, opacity: 0 }, ANIMATION_SPEED.FAST

    showOverlay: ->
      @elOverlay.animate { height: @elOverlayHeight, opacity: 1 }, ANIMATION_SPEED.FAST

  return {
    WorldUI: WorldUI
    }