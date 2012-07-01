models = require '../models'

exports.document = (req, res) ->
  if req.params.id?
    models.Document.find({ _id: req.params.id }).limit(1).exec (err, docs) ->
      if docs.length > 0
        res.json docs[0]
      else
        res.send(404)
  else
    models.Document.find({}).limit(10).exec (err, docs) ->
      res.json docs

exports.postDocument = (req, res) ->
  document = new models.Document
  for prop of req.body
    document[prop] = req.body[prop]
  document.save()
  res.send 200

exports.deleteDocument = (req, res) ->
  if req.params.id?
    models.Document.findById req.params.id, (err, document) ->
      document.remove (err) ->
        if !err?
          console.log 'deleted', req.params.id
          res.send '', 200
        else
          res.send 500
          console.log 'delete error', err