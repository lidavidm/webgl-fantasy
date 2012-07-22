deps = ["cs!./models/character", "cs!./models/behavior"]
define deps, (modules...) ->
  exports = {}

  for module in modules
    for prop of module
      exports[prop] = module[prop]
      window[prop] = module[prop]

  return exports