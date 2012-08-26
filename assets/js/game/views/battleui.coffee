deps = ["use!use/jquery", "use!use/jquery-ui", "cs!../view",
  "use!use/underscore", "cs!../resource", "cs!../data", "cs!./commonui"]
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
      for enemy in @options.battle.enemies
        enemyPos = enemy.sprite.position # from center of map
        cameraPos = @options.battle.camera.position()  # from center of map
        canvasPos = $("canvas").offset() # from topleft of page

        # from center of canvas
        offsetX = enemyPos.x - cameraPos.x
        offsetY = enemyPos.y - cameraPos.y

        # convert coords
        offsetX = canvasPos.left + 320 + offsetX
        offsetY = canvasPos.top + 320 - offsetY

        # center on sprite
        offsetX -= 32
        offsetY -= 32

        target = $("<div>")
          .css({
            position: 'absolute',
            left: offsetX,
            top: offsetY
            })
          .addClass('battle-target-selection')
          .data('enemy', enemy.npc.id)
          .appendTo($(document.body))
        target.click @actionHandlerTargetSelected

    actionHandlerTargetSelected: (e) ->
      console.log $(e.target).data('enemy')
      $('.battle-target-selection').remove()
      # result = action()

      # Waiting on https://trello.com/c/JhttUwgY
      # playAnim = (anim, times) =>
      #   animName = anim.animation()
      #   if times > 0
      #     @options.spriteManager.play @model.get('name'), 'battle', animName, ->
      #       playAnim(anim, times - 1)
      #   else
      #     @options.spriteManager.hide @model.get('name'), 'battle'
      #     # if anim.after()
      #     #   playAnim(anim.after(), anim.times())

      # if result.hitAnimation?
      #   for anim in result.hitAnimation
      #     if anim instanceof HIT_ANIMATION.DIRECTIONAL.klass
      #       anim.animation(@options.spriteManager.direction(
      #         @model.get('name'),
      #         @options.battle.enemies[0].npc.id
      #         ))
      #     playAnim(anim, result.hits)

      # console.log result.hits * result.damage

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
      @cooldownStatbar = new commonui.Statbar(
        $(@el).find('.statbar')[2],
        'cooldown')
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
      @camera = @controller.cameraView
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

        enemy.sprite.opacity = 1

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
      # TODO: more robust algorithm
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

    walk: (name, x, y) ->


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


  # One step in a sequence of animations/actions for a hit animation
  class HitAnimationStep
    constructor: ->
      @_after = null
      @_times = 1

    @_makeprop: (varname) ->
      func = (_value=null) ->
        if _value isnt null
          this[varname] = _value
          return this
        else
          return this[varname]

    after: @_makeprop "_after"
    times: @_makeprop "_times"
    animation: @_makeprop "_animation"

  class DirectionalAnimationStep extends HitAnimationStep

  class MoveToAnimationStep extends HitAnimationStep

  # Constants that implement semantic animations for CharacterBehavior
  class HIT_ANIMATION
    @_makeconstant: (klass) ->
      func = ->
        new klass
      func.klass = klass
      return func
    @DIRECTIONAL: @_makeconstant DirectionalAnimationStep
    @MOVETO: @_makeconstant MoveToAnimationStep

  return {
    Battle: Battle
    HIT_ANIMATION: HIT_ANIMATION
    }
