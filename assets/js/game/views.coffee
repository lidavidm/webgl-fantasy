deps = ["cs!./views/tilemap", "cs!./views/character", "cs!./views/camera",
  "cs!./views/worldui", "cs!./views/titleui", "cs!./views/npcs"]
define deps, (views...) ->
  exports = {}
  for view in views
    for obj of view
      exports[obj] = view[obj]
  return exports
