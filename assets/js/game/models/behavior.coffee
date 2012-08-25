deps = ["cs!../views/battleui"]
define deps, (battleui) ->
  class CharacterBehavior
    actions: ["Attack", "Item", "Run"]

    constructor: (@model) ->

    equipSlots: (item) ->
      return []

    action_attack: =>
      # 'action_' methods implement a battle action for a character.
      #
      # Return value should be an object consisting of:
      # ranged (boolean): whether attack is ranged
      # damage (int)
      # hits (int)
      # hitAnimation ([string]) - uses BattleSpriteManager.play
      # cooldown (float)


  class Santiago extends CharacterBehavior
    equipSlots: (item) ->
      switch item.type
        when "weapon"
          if item.data.type is "sword"
            return ["left", "right"]
      return []

    action_attack: =>
      equip = @model.get 'equip'
      [left, right] = [equip.left, equip.right]
      damage = 0
      hits = 0
      if left?
        damage += Math.floor((left.data.damage + 1) * Math.random())
        hits += Math.ceil(3 * Math.random())
      if right?
        damage += Math.floor((right.data.damage + 1) * Math.random())
        hits += Math.ceil(3 * Math.random())
      return {
        ranged: false
        hitAnimation: [battleui.HIT_ANIMATION.DIRECTIONAL]
        damage: damage
        hits: hits
        }

  class Elona extends CharacterBehavior

  return {
    Santiago: Santiago
    Elona: Elona
    }