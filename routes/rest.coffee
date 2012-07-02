exports.createRoutesFor = (name, model, app) ->
  app.get "/" + name + "/:id?", (req, res) ->
    if req.params.id?
      model.find({ _id: req.params.id }).limit(1).exec (err, docs) ->
        if docs.length > 0
          res.json docs[0]
        else
          res.send(404)
    else
      model.find({}).limit(10).exec (err, docs) ->
        res.json docs

  app.post "/" + name, (req, res) ->
    document = new model
    for prop of req.body
      document[prop] = req.body[prop]
    document.save()
    res.send 200

  app.delete "/" + name + "/:id", (req, res) ->
    if req.params.id?
      model.findById req.params.id, (err, document) ->
        document.remove (err) ->
          if !err?
            console.log 'deleted', req.params.id
            res.send '', 200
          else
            res.send 500
            console.log 'delete error', err