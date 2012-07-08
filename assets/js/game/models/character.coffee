deps = ["use!use/jquery", "use!use/backbone"]

define deps, ($, Backbone) ->
  class CharacterBehavior
    constructor: (@model) ->

    equipSlots: (item) ->
      return []

  class Santiago extends CharacterBehavior
    equipSlots: (item) ->
      switch item.type
        when "weapon"
          if item.data.type is "sword"
            return ["left", "right"]
      return []

  class CharacterInventory
    constructor: (@model) ->

    find: (id) ->
      index = @indexOf id
      if index >= 0
        return @model.get('inventory')[index]
      return null

    indexOf: (id) ->
      index = 0
      for item in @model.get 'inventory'
        if item.id == id
          return index
        index += 1
      return -1

    remove: (id) ->
      index = 0
      inventory = @model.get 'inventory'
      for item in inventory
        if item.id == id
          inventory.splice index, 1
          @model.set 'inventory', inventory
          return


  class Character extends Backbone.Model
    defaults:
      name: "(unnamed)"
      stats:
        health: 75
        mana: 50
      maxStats:
        health: 100
        mana: 100
      equip:
        head: null
        body: null
        feet: null
        left: null
        right: null
      inventory: []

    initialize: (attrs = {}) ->
      @set(_.defaults(attrs, @defaults))

      @inventory = new CharacterInventory @

      if attrs._id?
        @id = attrs._id

    behavesAs: (behavior) ->
      @behavior = new behavior @


  class CharacterList extends Backbone.Collection
    model: Character
    url: '/data/character'

  Characters = new CharacterList

  return {
    Character: Character
    Characters: Characters
    Santiago: Santiago
    }