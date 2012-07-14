define ["cs!./script-base"], (base) ->
  return {
    entered: (controller) ->
      console.log "entered"

    loadedNPC: base.global (controller, name, sprite, animation) ->
      console.log name, sprite
    }