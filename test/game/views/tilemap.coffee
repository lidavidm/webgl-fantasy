define ["use!use/jquery", "use!use/Three", "use!use/backbone", "cs!../resource"],
  ($, THREE, Backbone, resource) ->
    class Tilemap extends Backbone.View

      initialize: (@controller, @renderer, @scene, map) ->
        @setElement @renderer.domElement
        @objects = []
        map.done =>
          @initializeMap(map.path, map.data)
        @deferred = map.deferred

      update: =>

      initializeMap: (path, mapJson) ->
        [@height, @width] = [mapJson.height, mapJson.width]
        [@tileHeight, @tileWidth] = [mapJson.tileheight, mapJson.tilewidth]
  
        ts = THREE.ImageUtils.loadTexture(
          resource.Path.join path, mapJson.tilesets[0].image
        )

        @uvs = [[
          new THREE.UV(0, 0),
          new THREE.UV(0, 1),
          new THREE.UV(1, 1),
          new THREE.UV(1, 0)
        ]]

        [deltaU, deltaV] = [@tileWidth / ts.image.width ,
           @tileHeight / ts.image.height ]

        for y in [0...ts.image.height / @tileHeight]
          for x in [0...ts.image.width / @tileWidth]
            [u, v] = [x * deltaU, y * deltaV]
            @uvs.push [
              new THREE.UV(u, v),
              new THREE.UV(u, v + deltaV),
              new THREE.UV(u + deltaU, v + deltaV),
              new THREE.UV(u + deltaU, v)
            ]

        position = 0
        for layer in mapJson.layers.reverse()
          if layer.type is "objectgroup" then @parseObjects layer
          if layer.type isnt "tilelayer" then continue

          plane = new THREE.PlaneGeometry(
            @width * @tileWidth, @height * @tileHeight, @width, @height
          )

          plane.faceVertexUvs[0] = (@uvs[x] for x in layer.data)

          for i in [0...plane.faces.length]
            if layer.data[i] is 0
              plane.faces[i].materialIndex = 0
            else
              plane.faces[i].materialIndex = 1
          plane.materials[0] = new THREE.MeshBasicMaterial
            color: 0x000000,
            opacity: 0

          plane.materials[1] = new THREE.MeshBasicMaterial { map: ts }

          mesh = new THREE.Mesh plane, new THREE.MeshFaceMaterial
          mesh.rotation.x = Math.PI / 2
          @scene.add(mesh, position)
          position += 1

      parseObjects: (layerData) ->
        pixelWidth = @width * @tileWidth
        pixelHeight = @height * @tileHeight
        for object in layerData.objects
          object.y -= (pixelHeight / 2) - (object.height / 2)
          @objects.push object
          plane = new THREE.PlaneGeometry(object.width, object.height, 32, 32)
          mesh = new THREE.Mesh plane, new THREE.MeshBasicMaterial {
            color: 0xFF0000
            wireframe: true
            }
          mesh.rotation.x = Math.PI / 2
          mesh.position.x = object.x
          mesh.position.y = object.y
          @scene.add mesh, 2
          
  
    return { Tilemap: Tilemap }