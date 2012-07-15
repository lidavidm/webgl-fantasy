define
  CollisionManager: class CollisionManager
    constructor: ->
      @rects = []

    addRect: (rect) ->
      @rects.push rect

    clear: ->
      @rects = []

    faces: (rect, axis, orientation, range=1) ->
      # Algorithm from http://stackoverflow.com/questions/563198
      #
      # Axis is one of 'x' or 'y'.
      # Orientation is either +1 (right/up) or -1 (left/down).
      #
      # p is the "hand" of the character/rect. r is the endpoint.
      # q is the side of the rectangle we are checking. s is its endpoint.

      res = []

      px = rect.x + orientation * (rect.width / 2)
      py = rect.y + orientation * (rect.height / 2)

      if axis is 'x'
        rx = px + orientation
        ry = py
      else if axis is 'y'
        rx = px
        py = py + orientation
      else
        throw ("CollisionManager.faces: invalid axis: " + axis)

      for rectC in @rects
        # sides = [[[qx, qy], [sx, sy]]] * 4
        hWidth = rectC.width / 2
        hHeight = rectC.height / 2
        sides = [
          [[rectC.x + hWidth, rectC.y + hHeight],  # right
            [rectC.x + hWidth, rectC.y - hHeight]],
          [[rectC.x - hWidth, rectC.y + hHeight],  # left
            [rectC.x - hWidth, rectC.y - hHeight]],
          [[rectC.x - hWidth, rectC.y + hHeight],  # top
            [rectC.x + hWidth, rectC.y + hHeight]],
          [[rectC.x - hWidth, rectC.y - hHeight],  # bottom
            [rectC.x + hWidth, rectC.y - hHeight]]]

        for side in sides
          [[qx, qy], [sx, sy]] = side
          rXs = (rx * sy) - (ry * sx)

          if -0.01 < rXs < 0.01
            # Parallel or collinear, let’s ignore collinear
            continue

          tx = qx - px
          ty = qy - py

          t = (tx * sy) - (ty * sx)
          t /= rXs

          ux = qx - px
          uy = qy - py

          u = (ux * ry) - (uy * rx)
          u /= rXs

          res.push [t, u, rectC]
      return res


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