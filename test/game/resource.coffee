define
  Resource: class Resource
    constructor: (@path, @data) ->

  Path: class Path
    @join: (paths...) ->
      normalize = (component) ->
        if component.charAt(component.length - 1) isnt "/"
          component + "/"
        else
          component
      [prefix..., last] = paths
      normalized_paths = normalize component for component in prefix
      normalized_paths[0].concat normalized_paths[1..]..., last
