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
      action = $(e.target).data('action')
      action = @model.behavior['action_' + action]
      result = action()

      playTimes = result.hits
      playAnim = (anim) =>
        if playTimes > 0
          @options.spriteManager.play @model.get('name'), 'battle', anim, ->
            playAnim(anim)

        playTimes -= 1

      if result.hitAnimation?
        for anim in result.hitAnimation
          playAnim(anim)

      console.log result.hits * result.damage

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
        .append(@actionsTemplate { data: {actions: @model.behavior.actions}})


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
      @animate = {}
      @ticks = 6

    addCharacter: (characterView) ->
      # TODO make this less dependent on CharacterView’s attributes
      @sprites[characterView.model.id] = {
        world: [characterView.sprite, characterView.animation]
        battle: [characterView.battleSprite, characterView.battleAnimation]
        }
      characterView.battleSprite.position = characterView.sprite.position.clone()
      characterView.battleSprite.opacity = 0

    play: (name, type, anim, callback=->) ->
      animation = @sprites[name][type][1]
      animation.switchGroup anim
      @animate[name + type + anim] = [animation, 6, callback]
      @sprites[name][type][0].opacity = 1

    update: =>
      for animName of @animate
        [anim, ticks, callback] = @animate[animName]
        if ticks is 0
          reset = anim.next()
          if reset
            delete @animate[animName]
            callback()
          else
            @animate[animName][1] = 6
        else
          @animate[animName][1] -= 1


  return {
    Battle: Battle
    }
