models = require '../models'

exports.index = (req, res) ->
  res.render "index",
    title: "Game"
    layout: false
