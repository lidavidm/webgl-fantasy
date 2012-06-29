define ["use!use/jquery", "use!use/Three", "use!use/backbone", "cs!../resource"],
  ($, THREE, Backbone, resource) ->
    class Tilemap extends Backbone.View

      initialize: (@controller, @renderer, @scene, map) ->
        @setElement @renderer.domElement
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
            ), [[
            new THREE.UV(0, 0),
            new THREE.UV(0, 1),
            new THREE.UV(1, 1),
            new THREE.UV(1, 0)
            ]]]
        console.log @tilesets
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

          @uvs = @tilesets[0][1]
          ts = @tilesets[0][0]

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
                plane.faces[i].materialIndex = 1
            plane.materials[0] = new THREE.MeshBasicMaterial
              color: 0x000000,
              opacity: 0

            plane.materials[1] = new THREE.MeshBasicMaterial { map: ts }

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
            object.x += 1
            object.width -= 4
            object.y -= 1
            object.height -= 4
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