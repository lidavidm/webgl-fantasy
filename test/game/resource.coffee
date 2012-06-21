define ["use!use/jquery", "use!use/Three"], ($, THREE) ->
  class Resource
    constructor: (@path) ->
      @deferred = new $.Deferred
      
    done: (callback) ->
      @deferred.done callback

    resolve: (data) ->
      @data = data
      @deferred.resolve()

  class Path
    @join: (paths...) ->
      normalize = (component) ->
        if component.charAt(component.length - 1) isnt "/"
          component + "/"
        else
          component
      [prefix..., last] = paths
      normalized_paths = normalize component for component in prefix
      normalized_paths[0].concat normalized_paths[1..]..., last

    @split: (path) ->
      slash = path.lastIndexOf "/"
      head = path.substring 0, slash + 1
      tail = path.substring slash + 1
      return [head, tail]

  loadJSON = (url) ->
    path = Path.split(url)[0]
    resource = new Resource path
    $.getJSON url, (data) ->
      resource.resolve data
      
    return resource

  loadTexture = (url) ->
    path = Path.split(url)[0]
    resource = new Resource path
    texture = THREE.ImageUtils.loadTexture url, undefined, ->
      resource.resolve texture
      
    return resource

  return {
    Resource: Resource
    Path: Path
    loadJSON: loadJSON
    loadTexture: loadTexture
    }