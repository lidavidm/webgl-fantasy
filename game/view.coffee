define ->
  class View
    constructor: (@controller, @renderer, @scene, el, args...) ->
      @initialize controller, renderer, scene, el, args...

    initialize: (controller, renderer, scene, el, args...) ->

    update: ->

  return {
    View: View
    }