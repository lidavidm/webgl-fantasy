define ->
  class SpriteFrameAnimation
    constructor: (@sprite, @texture, @width, @height) ->
      @groups = {}
      @currentGroup = null
      @currentFrame = 0
      @widthInFrames = @texture.image.width / @width
      @heightInFrames = @texture.image.height / @height
      @deltaX = @width / @texture.image.width
      @deltaY = @height / @texture.image.height
  
    addGroupFrames: (name, frames) ->
      @groups[name] = frames

    addGroup: (name, start, end) ->
      frames = []
      while start[0] isnt end[0] or start[1] isnt end[1]
        frames.push [start[0] * @deltaX, start[1] * @deltaY]
        start[0] += 1
        if start[0] is end[0] and start[1] is end[1]
          frames.push [end[0] * @deltaX, end[1] * @deltaY]
          break
        if start[0] >= @widthInFrames
          start[0] = 0
          start[1] += @deltaY
  
      @addGroupFrames(name, frames)

    switchGroup: (name) ->
      @currentGroup = @groups[name]
      @currentFrame = 0

    next: ->
      @currentFrame += 1
      if @currentFrame >= @currentGroup.length then @currentFrame = 0
      @sprite.uvOffset.set @currentGroup[@currentFrame]...

  return { SpriteFrameAnimation: SpriteFrameAnimation }