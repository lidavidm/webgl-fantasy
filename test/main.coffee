define ["use!use/jquery", "cs!game/controllers"], ($, controllers) ->
  {
    main: ->
      console.log("Coffee main")
      app = new controllers.App
      $.when(app.loading...).then ->
        app.animate()
  }