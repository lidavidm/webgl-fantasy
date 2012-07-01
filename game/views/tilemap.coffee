define ["use!use/jquery", "use!use/Three", "cs!../view", "cs!../resource"],
  ($, THREE, view, resource) ->
    class Tilemap extends view.View

      initialize: (controller, renderer, scene, map) ->
        @objects = []
        @meshes = []
        map.done =>
          @initializeMap(map.path, map.data)
        @deferred = new $.Deferred

      update: =>

      initializeMap: (path, mapJson) ->
        [@height, @width] = [mapJson.height, mapJson.width]
        [@tileHeight, @tileWidth] = [mapJson.tileheight, mapJson.tilewidth]
        @properties = mapJson["properties"]
        @tilesets = []
        for ts in mapJson.tilesets
          @tilesets.push [resource.loadTexture(
            resource.Path.join(path, ts.image)
            ), []]
        # Only the first tileset needs a padding tile since TMX is
        # zero-indexed
        @tilesets[0][1].push [
          new THREE.UV(0, 0),
          new THREE.UV(0, 1),
          new THREE.UV(1, 1),
          new THREE.UV(1, 0)
          ]
        $.when((ts[0].deferred for ts in @tilesets)...).then =>
          for ts in @tilesets
            texture = ts[0] = ts[0].data
            [deltaU, deltaV] = [@tileWidth / texture.image.width ,
               @tileHeight / texture.image.height ]

            for y in [0...texture.image.height / @tileHeight]
              for x in [0...texture.image.width / @tileWidth]
                [u, v] = [x * deltaU, y * deltaV]
                ts[1].push [
                  new THREE.UV(u, v),
                  new THREE.UV(u, v + deltaV),
                  new THREE.UV(u + deltaU, v + deltaV),
                  new THREE.UV(u + deltaU, v)
                ]

          @uvs = []
          for ts in @tilesets
            for uvs in ts[1]
              @uvs.push uvs

          position = 0
          for layer in mapJson.layers
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
                uvMax = @tilesets[0][1].length
                mapIndex = 1
                for tileset in @tilesets
                  if layer.data[i] < uvMax
                    plane.faces[i].materialIndex = mapIndex
                    break
                  else
                    uvMax += @tilesets[mapIndex][1].length
                    mapIndex += 1

            plane.materials[0] = new THREE.MeshBasicMaterial
              color: 0x000000,
              opacity: 0

            x = 1
            for ts in @tilesets
              plane.materials[x] = new THREE.MeshBasicMaterial {
                map: ts[0]
                }
              x += 1

            mesh = new THREE.Mesh plane, new THREE.MeshFaceMaterial
            mesh.rotation.x = Math.PI / 2
            @scene.add(mesh, position)
            @meshes.push [mesh, position]
            position += 1

          @deferred.resolve()

      parseObjects: (layerData) ->
        pixelWidth = @width * @tileWidth
        pixelHeight = @height * @tileHeight
        for object in layerData.objects
          object.x -= (pixelWidth / 2) - (object.width / 2)
          object.y -= (pixelHeight / 2) - (object.height / 2)
          object.y *= -1
          @objects.push object
          if object.properties["collision"]
            # object.x += 1
            # object.width -= 4
            # object.y -= 1
            # object.height -= 4
            @controller.collision.addRect object

          # plane = new THREE.PlaneGeometry(object.width, object.height, 32, 32)
          # mesh = new THREE.Mesh plane, new THREE.MeshBasicMaterial {
          #   color: 0xFF0000
          #   wireframe: true
          #   }
          # mesh.rotation.x = Math.PI / 2
          # mesh.position.x = object.x
          # mesh.position.y = object.y
          # @scene.add mesh, 2

      changeTo: (resource) ->
        resource.done =>
          @controller.collision.clear()
          @objects = []
          for mesh in @meshes
            [mesh, layer] = mesh
            @scene.remove mesh, layer
          @initializeMap resource.path, resource.data
          # since the character has already been loaded by now
          @controller.character.setSpritePosition()
  
    return { Tilemap: Tilemap }