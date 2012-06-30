deps = ["cs!./views/tilemap", "cs!./views/character", "cs!./views/camera",
  "cs!./views/worldui", "cs!./views/titleui"]
define deps, (tm, char, cam, wui, tui) ->
    return {
      Tilemap: tm.Tilemap,
      Camera: cam.Camera,
      Character: char.Character,
      WorldUI: wui.WorldUI,
      TitleUI: tui.TitleUI
    }