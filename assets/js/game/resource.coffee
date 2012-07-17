define ["use!use/jquery", "use!use/Three"], ($, THREE) ->
  config =
    basePath: ''

  class Resource
    constructor: (@url) ->
      @deferred = new $.Deferred

    parent: ->
      Path.split(@url)[0]

    done: (callback) ->
      @deferred.done callback

    resolve: (data) ->
      @data = data
      @deferred.resolve()

    @fromTypeName: (type, name) ->
      resource = new Resource(Path.join(config.basePath, type, name))

    @fromPath: (path) ->
      resource = new Resource(path.path)

  class Path
    constructor: (@path) ->

    @join: (paths...) ->
      normalize = (component) ->
        if component.charAt(component.length - 1) isnt "/"
          component + "/"
        else
          component
      [prefix..., last] = paths
      normalized_paths = (normalize component for component in prefix)
      normalized_paths[0].concat normalized_paths[1..]..., last

    @split: (path) ->
      slash = path.lastIndexOf "/"
      head = path.substring 0, slash + 1
      tail = path.substring slash + 1
      return [head, tail]

  setBasePath = (path) ->
    config.basePath = path

  evalReference = (reference) ->
    # Parses statements such as @resource.texture(fighter) in tilemaps and
    # game objects as (for example) resource.loadTexture('fighter')

  loadJSON = (name) ->
    resource = Resource.fromTypeName "json", name
    $.getJSON resource.url, (new Date).getTime(), (data) ->
      resource.resolve data

    return resource

  loadTexture = (name) ->
    unless name instanceof Path
      resource = Resource.fromTypeName "texture", name
    else
      resource = Resource.fromPath name
    texture = THREE.ImageUtils.loadTexture resource.url, undefined, (image) ->
      resource.resolve texture

    return resource

  loadSpriteSheet = (name) ->
    unless name instanceof Path
      resource = Resource.fromTypeName "texture", name
    else
      resource = Resource.fromPath name

    texture = loadTexture(name)
    json = loadJSON(name)

    $.when(texture.deferred, json.deferred).done ->
      resource.resolve
        texture: texture
        sheet: json

    return resource

  return {
    Resource: Resource
    Path: Path
    loadJSON: loadJSON
    loadTexture: loadTexture
    setBasePath: setBasePath
    }