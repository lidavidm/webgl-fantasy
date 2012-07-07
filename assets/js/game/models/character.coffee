deps = ["use!use/jquery", "use!use/backbone"]

define deps, ($, Backbone) ->

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

      if attrs._id?
        @id = attrs._id

  class CharacterList extends Backbone.Collection
    model: Character
    url: '/data/character'

  Characters = new CharacterList

  return {
    Character: Character
    Characters: Characters
    }