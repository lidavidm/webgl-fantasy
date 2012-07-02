deps = ["cs!./models/character"]
define deps, (char) ->
  exports = {}

  for prop of char
    exports[prop] = char[prop]

  return exports