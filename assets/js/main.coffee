define ["use!use/jquery", "cs!game/controllers"], ($, controllers) ->
  {
    main: ->
      app = new controllers.Title
      $(document).ready ->
        $.when(app.loading...).then ->
          app.animate()
  }