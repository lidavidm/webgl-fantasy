define ["cs!./script-base"], (base) ->
  return {
    entered: (controller, data) ->
      console.log "entered"

    loadedNPC: base.global (controller, data, name, sprite, animation, object) ->
      if name is "thief"
        controller.cameraView.scrollTo
          x: 0.5 * (controller.character.sprite.position.x + sprite.position.x)
          y: 0.5 * (controller.character.sprite.position.y + sprite.position.y)
        controller.ui.dialogue object, data[object.dialogue], ->
          controller.cameraView.scrollTo controller.character.sprite.position

    }