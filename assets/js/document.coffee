#= require jquery
#= require underscore
#= require backbone
#= require backbone.localStorage

$ ->
  class Document extends Backbone.Model
    defaults:
      type: "webpage"
      author: null
      date: new Date
      name: "(unnamed)"
      content: ""
      tags: ['no tags']
      metadata: {}

    initialize: (attrs) ->
      attrs = {} if not attrs?
      @defaults.date = new Date
      attrs.date = new Date(attrs.date) if attrs.date?
      @set(_.defaults attrs, @defaults)
      if attrs._id?
        @id = attrs._id

    toJSON: ->
      date = @get 'date'
      json = super()
      json.date = date.toLocaleDateString()
      json
  
  class DocumentList extends Backbone.Collection
    model: Document  
    url: '/document'
    #localStorage: new Store("documents")

  class DocumentView extends Backbone.View
    tagName: "li"
    template: _.template($("#document-template").html())

    initialize: ->
      @model.bind 'change', this.render
      @model.view = this

    render: =>
      $(@el).html(@template({ data: @model.toJSON() }))
      $(@el).children('button.delete').click =>
        @model.destroy {
          success: =>
            $(@el).slideUp 800, =>
              $(@el).remove()
          error: (args...) -> console.log 'error', args
        }
      this

  class AppView extends Backbone.View
    el: $ "#app"
    events:
      "click #addDocument": "addDocument"

    initialize: ->
      Documents.fetch()
      Documents.bind "add", @addOne

      Documents.bind "reset", =>
        Documents.each @addOne

    addOne: (document) =>
      view = new DocumentView { model: document }
      $("#documents > ul").append view.render().el
      $(view.el).hide().fadeIn()

    render: =>

    addDocument: (e) ->
      e.preventDefault()
      name = $("#add-name").val()
      content = $("#add-content").val()
      if name
        Documents.create { name: name, content: content }
      return false

  Documents = new DocumentList
  App = new AppView
