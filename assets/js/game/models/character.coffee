deps = ["use!use/jquery", "use!use/backbone"]

define deps, ($, Backbone) ->

  class Character extends Backbone.Model
    defaults:
      name: "(unnamed)"
      stats:
        health: 100
        mana: 100
      inventory: []

    initialize: (attrs = {}) ->
      @set(_.defaults(attrs, @defaults))

      if attrs._id?
        @id = attrs._id

  class CharacterList extends Backbone.Collection
    model: Character
    url: '/character'

  Characters = new CharacterList

  return {
    Stats: Stats
    Character: Character
    Characters: Characters
    }