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
        .html(@template @model.toJSON())

      $(@el)
        .find('.statbar')
        .css({ marginRight: "2em" })

      $($(@el).find('.statbar')[0]).children('div')
        .html('hp ' + @model.get("stats").health)
        .width(10)
        .animate {
          width: (100 *
            (@model.get("stats").health / @model.get("maxStats").health))
          },
          { duration: ANIMATION_SPEED.SLOW }
      $($(@el).find('.statbar')[1]).children('div')
        .html('mp ' + @model.get("stats").mana)
        .width(10)
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
        .css { textAlign: 'center' }

      @controller.keyState.on "ui_keydown", (keyCode) =>
        if keyCode is 81  # Q
          if @controller.paused
            @controller.unpause()
            @characterOverlay.hide()
            @showOverlay()
          else
            @controller.pause @
            @characterOverlay.show()
            @hideOverlay()

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
      @elOverlay.fadeOut ANIMATION_SPEED.FAST

    showOverlay: ->
      @elOverlay.fadeIn ANIMATION_SPEED.FAST

  return {
    WorldUI: WorldUI
    }