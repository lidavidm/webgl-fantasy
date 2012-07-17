deps = ["use!use/jquery", "use!use/jquery-ui", "cs!../view", "use!use/underscore",
  "cs!../resource", "cs!../data"]
define deps, ($, $2, view, _, resource, data) ->

  ANIMATION_SPEED =
    FAST: 300
    SLOW: 600

  class Overlay extends view.UIView
    tagName: "div"

    hide: ->
    show: ->
      @render()
      $(@el).fadeIn(ANIMATION_SPEED.FAST).slideDown(ANIMATION_SPEED.FAST)

    render: =>
      $(@el)
        .addClass('ui-overlay')
        .html('test')

  class BattleUI extends view.View
    initialize: (el, args...) ->
      @el = $(el)
      @overlay = new Overlay
          model: @model
      @el.append @overlay.el
      @resolve()

    start: (@enemies...) ->
      @controller.pause @
      @overlay.show()

  return {
    BattleUI: BattleUI
    }
