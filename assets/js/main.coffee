define ["use!use/jquery", "cs!game/resource", "cs!game/controllers"], ($, resource, controllers) ->
  {
    main: ->
      resource.setBasePath "gamedata"
      app = new controllers.Title

      if not window.performance.now?
        if window.performance.webkitNow?
          window.performance.now = window.performance.webkitNow
        else
          window.performance.now = -> (new Date).getTime()

      $(document).ready ->
        $.when(app.loading...).then ->
          app.animate(window.performance.webkitNow())
  }