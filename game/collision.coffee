define
  CollisionManager: class CollisionManager
    constructor: ->
      @rects = []

    addRect: (rect) ->
      @rects.push rect

    clear: ->
      @rects = []

    collidesAny: (rect) ->
      for rectC in @rects
        if @collides rectC, rect
          return true
      return false

    collidesDirections: (rect) ->
      directions = { x: 0, y: 0 }
      
      for rectC in @rects
        if @collides rectC, rect
          if rectC.properties?
            for prop of rectC.properties
              directions[prop] = rectC.properties[prop]
              
          halfWidth = (rectC.width / 2) - 2
          halfHeight = (rectC.height / 2) - 2
          if rect.x - (rect.width / 2) >= rectC.x + halfWidth
            directions.x = 1
          else if rect.x + (rect.width / 2) <= rectC.x - halfWidth
            directions.x = -1
          if rect.y - (rect.height / 2) >= rectC.y + halfHeight
            directions.y = 1
          if rect.y + (rect.height / 2) <= rectC.y - halfHeight
            directions.y = -1

      return directions

    collides: (rectA, rectB) ->
      halfWidthA = rectA.width / 2
      halfHeightA = rectA.height / 2
      halfWidthB = rectB.width / 2
      halfHeightB = rectB.height / 2
      
      if rectB.x + halfWidthB >= rectA.x - halfWidthA
        if rectB.x - halfWidthB <= rectA.x + halfWidthA
          if rectB.y + halfHeightB >= rectA.y - halfHeightA
            if rectB.y - halfHeightB <= rectA.y + halfHeightA
              return true
              
      return false