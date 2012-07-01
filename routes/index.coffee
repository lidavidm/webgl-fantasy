models = require '../models'

document = require('./document')
exports.document = document.document
exports.postDocument = document.postDocument
exports.deleteDocument = document.deleteDocument

exports.index = (req, res) ->
  res.render "index",
    title: "Mneme Notes"
