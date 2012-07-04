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

  app.post prefix + "create", (req, res) ->
    document = new model
    console.log req.body
    for prop of req.body
      document[prop] = req.body[prop]
    document.save()
    res.redirect prefix