define ["use!use/jquery", "use!use/Three", "use!use/backbone", "cs!./resource"],
  ($, THREE, Backbone, resource) ->
    class Tilemap extends Backbone.View
      events: {}

      initialize: (@renderer, @scene, mapJson) ->
        @initializeMap(mapJson)

      update: =>

      initializeMap: (mapJson) ->
        [path, mapJson] = [mapJson.path, mapJson.data]

        [@height, @width] = [mapJson.height, mapJson.width]
        [@tileHeight, @tileWidth] = [mapJson.tileheight, mapJson.tilewidth]
  
        ts = THREE.ImageUtils.loadTexture(
          resource.Path.join path, mapJson.tilesets[0].image
        )

        @uvs = [null]

        [deltaU, deltaV] = [@tileWidth / ts.image.width ,
           @tileHeight / ts.image.height ]

        for x in [0...ts.image.width / @tileWidth]
          for y in [0...ts.image.height / @tileHeight]
            [u, v] = [x * deltaU, y * deltaV]
            @uvs.push [
              new THREE.UV(u, v),
              new THREE.UV(u, v + deltaV),
              new THREE.UV(u + deltaU, v + deltaV),
              new THREE.UV(u + deltaU, v)
            ]

        plane = new THREE.PlaneGeometry(
          @width * @tileWidth, @height * @tileHeight, @width, @height
        )

        plane.faceVertexUvs[0] = (@uvs[x] for x in mapJson.layers[0].data)

        mesh = new THREE.Mesh plane, new THREE.MeshBasicMaterial { map: ts }
        mesh.rotation.x = -Math.PI / 2

        @scene.add(mesh)

    return {
      Tilemap: Tilemap
    }