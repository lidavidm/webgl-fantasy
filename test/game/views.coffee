deps = ["cs!./views/tilemap", "cs!./views/character", "cs!./views/camera",
  "cs!./views/worldui"]
define deps, (tm, char, cam, wui) ->
    return {
      Tilemap: tm.Tilemap,
      Camera: cam.Camera,
      Character: char.Character,
      WorldUI: wui.WorldUI
    }