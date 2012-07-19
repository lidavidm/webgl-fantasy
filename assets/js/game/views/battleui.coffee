deps = ["use!use/jquery", "use!use/jquery-ui", "cs!../view", "use!use/underscore",
  "cs!../resource", "cs!../data", "cs!./commonui"]
define deps, ($, $2, view, _, resource, data, commonui) ->
  ANIMATION_SPEED = commonui.ANIMATION_SPEED

  class Overlay extends view.UIView
    tagName: "div"
    template: _.template($("#templ-battle-overlay").html())
    statsTemplate: _.template($("#templ-battle-stats").html())
    actionsTemplate: _.template($("#templ-battle-actions").html())

    hide: ->
    show: ->
      @render()
      $(@el).fadeIn(ANIMATION_SPEED.FAST).slideDown(ANIMATION_SPEED.FAST)

    render: =>
      $(@el)
        .addClass('ui-overlay')
        .addClass('templ-battle-overlay')
        .html(@template())

      $(@el).find('.stats').append($(@statsTemplate { data: @model.toJSON()}))

      @hpStatbar = new commonui.Statbar($(@el).find('.statbar')[0], 'hp')
        .maxValue(@model.get('maxStats').health)
        .value(@model.get('stats').health)
        .show()
      @mpStatbar = new commonui.Statbar($(@el).find('.statbar')[1], 'mp')
        .maxValue(@model.get('maxStats').mana)
        .value(@model.get('stats').mana)
        .show()

      $(@el).find('.actions').append(@actionsTemplate { data: {actions: ["Attack","Fight","Run"]}})


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
