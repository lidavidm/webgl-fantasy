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

        @uvs = [[
          new THREE.UV(0, 0),
          new THREE.UV(0, 0),
          new THREE.UV(0, 0),
          new THREE.UV(0, 0)
        ]]

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
        console.log mapJson.layers
        for layer in mapJson.layers.reverse()
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
          plane.materials[0] = new THREE.MeshBasicMaterial {
            color: 0x00000000,
            wireframe: true
          }

          plane.materials[1] = new THREE.MeshBasicMaterial {
            map: ts
          }

          mesh = new THREE.Mesh plane, new THREE.MeshFaceMaterial
          mesh.rotation.x = -Math.PI / 2
          console.log mapJson

          @scene.add(mesh)
          console.log mesh

    return {
      Tilemap: Tilemap
    }