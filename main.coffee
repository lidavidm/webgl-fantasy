define ["use!use/jquery", "cs!game/controllers"], ($, controllers) ->
  {
    main: ->
      app = new controllers.Title
      $(document).ready ->
        
        $("#ui").css {
          width: 640,
          height: 640,
          display: "block",
          position: "absolute",
          left: 0,
          top: 0,
          color: "#FFFFFF",
          fontFamily: "Cantarell"
          }
        $.when(app.loading...).then ->
          app.animate()
  }