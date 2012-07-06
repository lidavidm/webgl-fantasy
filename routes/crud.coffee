exports.createCRUDFor = (name, model, app) ->
  prefix = "/admin/" + name + "/"

  fields = (field for field of model.schema.paths)
  
  app.get prefix, (req, res) ->
    model.find {}, (err, docs) ->
      res.render "crud_list",
        title: name
        name: name
        objects: docs
        prefix: prefix
        fields: fields

  app.get prefix + "new", (req, res) ->
    res.render "crud_new",
      title: name
      name: name
      prefix: prefix
      model: model

  app.get prefix + "edit/:id", (req, res) ->
    model.findById req.params.id, (err, document) ->
      res.render "crud_edit",
        title: name
        name: name
        prefix: prefix
        model: document

  app.post prefix + "create", (req, res) ->
    document = new model
    console.log req.body
    for prop of req.body
      document[prop] = req.body[prop]
    document.save()
    res.redirect prefix

  app.post prefix + "update", (req, res) ->
    model.findById req.body._id, (err, document) ->
      console.log req.body
      console.log document.schema.path('info')
      for prop of req.body
        if prop != "_id"
          if (document.schema.path(prop).instance == 'ObjectID' and not req.body[prop]) then continue
          document[prop] = req.body[prop]
      document.save()
      res.redirect prefix

  app.delete prefix + "delete/:id", (req, res) ->
    model.findById req.params.id, (err, document) ->
      document.remove (err) ->
        if !err?
          res.send '', 200
        else
          res.send 500