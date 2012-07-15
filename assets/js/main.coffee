define ["use!use/jquery", "cs!game/resource", "cs!game/controllers"], ($, resource, controllers) ->
  {
    main: ->
      resource.setBasePath "gamedata"
      app = new controllers.Title
      $(document).ready ->
        $.when(app.loading...).then ->
          app.animate()
  }