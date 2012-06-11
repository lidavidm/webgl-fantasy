define ["cs!game/controllers"], (controllers) ->
  {
    main: ->
      console.log("Coffee main")
      app = new controllers.App
      app.loading.done ->
        app.animate()
  }