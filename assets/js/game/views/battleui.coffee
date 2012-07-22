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
      "click .name": "toggle"
      "click .action": "actionHandler"

    hide: ->
      @

    show: ->
      @render()
      $(@el).fadeIn(ANIMATION_SPEED.FAST)
      @

    toggle: ->
      if $(@el).hasClass 'expanded'
        $(@el)
          .removeClass('expanded', ANIMATION_SPEED.FAST)
      else
        $(@el)
          .addClass('expanded', ANIMATION_SPEED.FAST)

    actionHandler: (e) ->
      if $(e.target).data('action') is 'attack'
        @options.spriteManager.play @model.get('name'), 'battle', 'left'

    mousedown: =>
      @expand()

    mouseup: =>
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
        .append(@actionsTemplate { data: {actions: ["Attack","Spell","Run"]}})


  class Battle extends view.View
    initialize: (el, args...) ->
      @el = $(el)
      @overlays = {}

      @manager = new BattleSpriteManager

      for model in @model
        @overlays[model.id] = new Overlay
          model: model
          spriteManager: @manager
        @el.append @overlays[model.id].el
      @resolve()

    start: (@enemies...) ->
      @controller.pause @
      @manager.addCharacter @controller.character
      for overlay in @overlays
        overlay.options.spriteManager = @manager

      @overlays[@model[0].id].show().toggle()
      @overlays[@model[1].id].show()

    update: =>
      @manager.update()


  class BattleSpriteManager
    constructor: ->
      @sprites = {}
      @animate = []
      @ticks = 6

    addCharacter: (characterView) ->
      # TODO make this less dependent on CharacterView’s attributes
      @sprites[characterView.model.id] = {
        world: [characterView.sprite, characterView.animation]
        battle: [characterView.battleSprite, characterView.battleAnimation]
        }
      characterView.battleSprite.position = characterView.sprite.position.clone()
      characterView.battleSprite.opacity = 0

    play: (name, type, anim) ->
      console.log 'play', @sprites[name][type], name, anim
      animation = @sprites[name][type][1]
      animation.switchGroup anim
      @animate.push animation
      @sprites[name][type][0].opacity = 1

    update: =>
      if @animate.length
        if @ticks is 0
          @ticks = 6
          for anim in @animate
            anim.next()
        else
          @ticks -= 1


  return {
    Battle: Battle
    }
