deps = ["use!use/jquery", "use!use/jquery-ui", "cs!../view", "use!use/underscore",
  "cs!../resource", "cs!../data"]
define deps, ($, $2, view, _, resource, data) ->

  ANIMATION_SPEED =
    FAST: 300
    SLOW: 600

  class CharacterOverlay extends view.UIView
    tagName: "div"

    template: _.template $("#templ-character-overlay").html()
    templateInventoryItem: _.template $("#templ-inventory-item").html()

    hide: ->
      $(@el).fadeOut ANIMATION_SPEED.FAST

    show: ->
      @render()
      $(@el).fadeIn ANIMATION_SPEED.FAST

    render: =>
      $(@el)
        .addClass('templ-character-overlay')
        .html(@template { data: @model.toJSON(), inventoryItem: @templateInventoryItem })

      equip = @model.get 'equip'
      for slot of equip
        if equip[slot]?
          $("#equip-slot-"+slot).append(
            $(@templateInventoryItem { item: equip[slot] }))

      $(@el)
        .find('.inventory-item')
        .draggable
          revert: true

      $(@el)
        .find('.inventory ul')
        .droppable
          drop: (event, ui) =>
            $(ui.draggable).appendTo($(event.target)).css { left: 0, top: 0 }

      $(@el)
        .find('.equip-slot')
        .droppable
          drop: (event, ui) =>
            itemId = $(ui.draggable).data('itemId')

            slot = $.trim $(event.target).html()
            slot = slot.substring(0, slot.length - 1)

            if slot in @model.behavior.equipSlots(@model.inventory.find itemId)
              equip = @model.get 'equip'
              equip[slot] = data[itemId]
              @model.inventory.remove itemId

              @model.set { equip: equip }
              ui.draggable
                .appendTo($(event.target))
                .css
                  left: 0
                  top: 0
            else
              ui.draggable.css { left: 0, top: 0 }

      $(@el)
        .find('.statbar')
        .css({ marginRight: "2em" })

      $($(@el).find('.statbar')[0])
        .html('<div/><span>' + @model.get("stats").health + ' hp</span>')
        .children('div')
        .width(0)
        .animate {
          width: (100 *
            (@model.get("stats").health / @model.get("maxStats").health))
          },
          { duration: ANIMATION_SPEED.SLOW }
      $($(@el).find('.statbar')[1])
        .html('<div/><span>' + @model.get("stats").mana + ' mana</span>')
        .children('div')
        .width(0)
        .animate {
          width: (100 *
            (@model.get("stats").mana / @model.get("maxStats").mana))
          },
          { duration: ANIMATION_SPEED.SLOW }


  class DialogueOverlay extends view.UIView
    tagName: "div"

    template: _.template $("#templ-dialogue-overlay").html()

    hide: ->
      $(@el).fadeOut ANIMATION_SPEED.FAST

    show: ->
      @render()
      $(@el).fadeIn ANIMATION_SPEED.FAST

    render: =>
      $(@el)
        .addClass('templ-dialogue-overlay')
        .html(@template { data: @model.toJSON() })


  class WorldUI extends view.View
    initialize: (el, args...) ->
      @el = $(el)
      @elOverlay = $("<div></div>")
        .appendTo(@el)
        .css { textAlign: 'center', color: "#FFF" }

      @controller.keyState.on "ui_keydown", (keyCode) =>
        if keyCode is 81  # Q
          if @controller.paused
            @controller.unpause()
            @showOverlay()
            @characterOverlay.hide()
          else
            @controller.pause @
            @hideOverlay()
            @characterOverlay.show()

      @controller.character.deferred.done =>
        @characterOverlay = new CharacterOverlay {
          model: @controller.character.model }
        @el.append @characterOverlay.el

      @resolve()

    update: ->
    overlay: (text) ->
      @elOverlay.html text

    clearOverlay: ->
      @elOverlay.html ""

    hideOverlay: ->
      @elOverlayHeight = @elOverlay.height()
      @elOverlay.animate { height: 0, opacity: 0 }, ANIMATION_SPEED.FAST

    showOverlay: ->
      @elOverlay.animate { height: @elOverlayHeight, opacity: 1 }, ANIMATION_SPEED.FAST

  return {
    WorldUI: WorldUI
    }