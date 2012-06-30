define ["use!use/jquery", "cs!game/controllers"], ($, controllers) ->
  {
    main: ->
      app = new controllers.Title
      $.when(app.loading...).then ->
        app.animate()
  }