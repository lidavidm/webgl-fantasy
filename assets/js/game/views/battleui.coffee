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
        else
          @options.spriteManager.hide @model.get('name'), 'battle'

        playTimes -= 1

      if result.hitAnimation?
        for anim in result.hitAnimation
          if anim is HIT_ANIMATION.DIRECTIONAL
            anim = @options.spriteManager.direction @model.get('name'),
              @options.battle.enemies[0].npc.id
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
          battle: this
        @el.append @overlays[model.id].el
      @resolve()

    start: (@enemies...) ->
      @controller.pause @
      @manager.addCharacter @controller.character.model.id,
        @controller.character.sprite,
        @controller.character.animation,
        @controller.character.battleSprite,
        @controller.character.battleAnimation

      for enemy in enemies
        @manager.addCharacter enemy.npc.id,
          enemy.sprite,
          enemy.animation,
          enemy.sprite,
          enemy.animation

      @overlays[@model[0].id].show().toggle()
      @overlays[@model[1].id].show()

    update: =>
      @manager.update()


  class BattleSpriteManager
    constructor: ->
      @sprites = {}
      @animate = {}
      @ticks = 6

    addCharacter: (id, worldSprite, worldAnim, battleSprite, battleAnim) ->
      @sprites[id] = {
        world: [worldSprite, worldAnim]
        battle: [battleSprite, battleAnim]
        }
      battleSprite.position = worldSprite.position.clone()
      battleSprite.opacity = 0

    direction: (attacker, defender) ->
      attacker = @sprites[attacker].world[0]
      defender = @sprites[defender].world[0]

      if attacker.position.x < defender.position.x
        return "right"
      else if attacker.defender.x > defender.position.x
        return "left"


    play: (name, type, anim, callback=->) ->
      animation = @sprites[name][type][1]
      animation.switchGroup anim
      @animate[name + type + anim] = [animation, 6, callback]
      @sprites[name][type][0].opacity = 1

    hide: (name, type) ->
      @sprites[name][type][0].opacity = 0

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


  # Constants that implement semantic animations for CharacterBehavior
  class HIT_ANIMATION
    @DIRECTIONAL: "@direction"


  return {
    Battle: Battle
    HIT_ANIMATION: HIT_ANIMATION
    }
