define ["use!use/jquery"], ($) ->
  ANIMATION_SPEED =
    FAST: 300
    SLOW: 600

  class Statbar
    constructor: (@el, @label) ->
      @val = 0
      @

    maxValue: (@maxVal) -> @
    value: (@val) -> @
    show: ->
      $(@el)
        .html('<div/><span>' + @val + ' ' + @label + '</span>')
        .children('div')
        .width(0)
        .animate({
          width: (100 *
            (@val / @maxVal))
          },
          { duration: ANIMATION_SPEED.SLOW })
      @

  return {
    ANIMATION_SPEED: ANIMATION_SPEED
    Statbar: Statbar
    }