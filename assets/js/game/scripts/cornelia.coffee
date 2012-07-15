define ["cs!./script-base"], (base) ->
  return {
    entered: (controller, data) ->
      console.log "entered"

    loadedNPC: base.global (controller, data, name, sprite, animation, object) ->
      if name is "thief"
        controller.ui.dialogue data[object.dialogue]
    }