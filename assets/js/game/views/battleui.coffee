deps = ["use!use/jquery", "use!use/jquery-ui", "cs!../view", "use!use/underscore",
  "cs!../resource", "cs!../data", "cs!./commonui"]
define deps, ($, $2, view, _, resource, data, commonui) ->
  ANIMATION_SPEED = commonui.ANIMATION_SPEED

  class Overlay extends view.UIView
    tagName: "div"
    template: _.template($("#templ-battle-overlay").html())
    charTemplate: _.template($("#templ-battle-char").html())
    actionsTemplate: _.template($("#templ-battle-actions").html())

    events:
      "mouseenter .main": "mouseover"
      "mouseleave .main": "mouseout"

    hide: ->
      @

    show: ->
      @render()
      $(@el).fadeIn(ANIMATION_SPEED.FAST)
      @

    expand: ->
      $(@el)
        .addClass('expanded', ANIMATION_SPEED.FAST)

    contract: ->
      $(@el)
        .removeClass('expanded', ANIMATION_SPEED.FAST)

    mouseover: =>
      @expand()

    mouseout: =>
      @contract()

    render: =>
      $(@el)
        .addClass('ui-overlay')
        .addClass('templ-battle-overlay')
        .html(@template())

      character = $(@el).find('.character')
        .append($(@charTemplate { data: @model.toJSON()}))

      @hpStatbar = new commonui.Statbar($(@el).find('.statbar')[0], 'hp')
        .maxValue(@model.get('maxStats').health)
        .value(@model.get('stats').health)
        .show()
      @mpStatbar = new commonui.Statbar($(@el).find('.statbar')[1], 'mp')
        .maxValue(@model.get('maxStats').mana)
        .value(@model.get('stats').mana)
        .show()
      @cooldownStatbar = new commonui.Statbar($(@el).find('.statbar')[2], 'cooldown')
        .maxValue(5)
        .value(2.5)
        .show()

      character.find('.actions')
        .append(@actionsTemplate { data: {actions: ["Attack","Fight","Run"]}})


  class BattleUI extends view.View
    initialize: (el, args...) ->
      @el = $(el)
      @overlays = {}
      for model in @model
        console.log model
        @overlays[model.id] = new Overlay
          model: model
        @el.append @overlays[model.id].el
      @resolve()

    start: (@enemies...) ->
      @controller.pause @
      @overlays[@model[0].id].show().expand()
      @overlays[@model[1].id].show()

  return {
    BattleUI: BattleUI
    }
