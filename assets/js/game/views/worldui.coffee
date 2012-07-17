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
        .addClass('ui-overlay')
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
          start: (event, ui) =>
            itemId = $(event.target).data 'itemId'

            for slot in $(@el).find('.equip-slot')
              slotEl = slot
              slot = $.trim $(slot).html()
              slot = slot.substring(0, slot.length - 1)
              if slot in @model.behavior.equipSlots(@model.inventory.find itemId)
                $(slotEl).addClass 'allowable', ANIMATION_SPEED.FAST
          stop: =>
            $(@el).find('.equip-slot').removeClass 'allowable', ANIMATION_SPEED.FAST

      $(@el)
        .find('.inventory ul')
        .droppable
          drop: (event, ui) =>
            $(ui.draggable).appendTo($(event.target)).css { left: 0, top: 0 }
            $(@el).find('.equip-slot').removeClass 'allowable', ANIMATION_SPEED.FAST

      $(@el)
        .find('.equip-slot')
        .droppable
          drop: (event, ui) =>
            $(@el).find('.equip-slot').removeClass 'allowable', ANIMATION_SPEED.FAST
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
    saidTemplate: _.template $("#templ-dialogue-said").html()
    heardTemplate: _.template $("#templ-dialogue-heard").html()
    sayTemplate: _.template $("#templ-dialogue-say").html()

    hide: ->
      $(@el).fadeOut ANIMATION_SPEED.FAST
      @callback() unless not @callback?

    show: (@callback) ->
      @render()
      $(@el).fadeIn ANIMATION_SPEED.FAST

    addToHistory: (role, name, text) ->
      if role is 'npc'
        $(@el).find('.history').append @heardTemplate
          name: name
          text: text
      else if role is 'party'
        $(@el).find('.history').append @saidTemplate
          name: name
          text: text
      $('.history').scrollTo
      $(".history").animate {
        scrollTop: $(".history").prop("scrollHeight") - $('.history').height()
        }, ANIMATION_SPEED.FAST / 2

    npcSays: (choice) ->
      @addToHistory 'npc', @npc.name, @tree.hear[choice]
      choices = @tree.progression[choice]
      for choice in choices
        $(@sayTemplate { text: @tree.say[choice] })
          .click(@handleSay)
          .data('choice', choice)
          .appendTo(@choices)

    partySays: (choice) ->
      @addToHistory 'party', "Santiago", @tree.say[choice]
      @choices.html('')
      reaction = @tree.progression[choice]
      if @tree.hear[reaction]?
        @npcSays reaction
      else
        @hide()

    handleSay: (e) =>
      choice = $(e.target).data('choice')
      @partySays choice

    render: =>
      $(@el)
        .addClass('templ-dialogue-overlay')
        .addClass('ui-overlay')
        .html(@template { tree: @tree, npc: @npc })
        .hide()

      @choices = $(@el).find('.choices ol')

      if @tree.starter is 'npc'
        @npcSays @tree.start

    tree: (@tree) ->
    npc: (@npc) ->


  class WorldUI extends view.View
    @WORLD = 'world'
    @CHARACTER = 'character'
    @DIALOGUE = 'dialogue'

    initialize: (el, args...) ->
      @el = $(el)
      @state = WorldUI.WORLD
      @elOverlay = $("<div></div>")
        .appendTo(@el)
        .css { textAlign: 'center', color: "#FFF" }

      @controller.keyState.on "ui_keydown", (keyCode) =>
        if keyCode is 81  # Q
          if @controller.paused and @state is WorldUI.CHARACTER
            @state = WorldUI.WORLD
            @controller.unpause()
            @showOverlay()
            @characterOverlay.hide()
          else if @state is WorldUI.WORLD
            @state = WorldUI.CHARACTER
            @controller.pause @
            @hideOverlay()
            @characterOverlay.show()

      @controller.character.deferred.done =>
        @characterOverlay = new CharacterOverlay {
          model: @controller.character.model }
        @el.append @characterOverlay.el

        @dialogueOverlay = new DialogueOverlay {
          model: @controller.character.model }
        @el.append @dialogueOverlay.el

        @resolve()

    update: ->

    dialogue: (npc, tree, callback=->) ->
      @state = WorldUI.DIALOGUE
      @controller.pause @
      @dialogueOverlay.npc npc
      @dialogueOverlay.tree tree
      @dialogueOverlay.show =>
        @state = WorldUI.WORLD
        @controller.unpause()
        callback()

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