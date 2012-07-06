deps = ["use!use/jquery", "use!use/backbone"]

define deps, ($, Backbone) ->

  class Item extends Backbone.Model
    initialize: (attrs) ->
      @id = attrs._id
      if attrs.type is "weapon"
        @set 'info', ItemWeapons.get(attrs.info)

  class ItemWeapon extends Backbone.Model
    initialize: (attrs) ->
      @id = attrs._id

  class ItemList extends Backbone.Collection
    model: Item
    url: '/data/Item'

  class ItemWeaponList extends Backbone.Collection
    model: ItemWeapon
    url: '/data/ItemWeapon'

  ItemWeapons = new ItemWeaponList
  ItemWeapons.fetch {
    success: ->
      Items.fetch()
    }

  Items = new ItemList

  return {
    Item: Item
    Items: Items
    }