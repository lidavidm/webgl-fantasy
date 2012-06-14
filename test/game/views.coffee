deps = ["cs!./views/tilemap", "cs!./views/character", "cs!./views/camera"]
define deps, (tm, char, cam) ->
    return {
      Tilemap: tm.Tilemap,
      Camera: cam.Camera
    }