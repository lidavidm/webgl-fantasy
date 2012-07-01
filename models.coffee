mongoose = require 'mongoose'

mongoose.connect 'mongodb://localhost/test'

CommentSchema = new mongoose.Schema
  comment: String
  date: Date

DocumentSchema = new mongoose.Schema
  type: String
  author: String
  date: Date
  name: String
  content: String
  comments: [CommentSchema]
  tags: [String]
  metadata: {}

exports.Document = mongoose.model 'Document', DocumentSchema
exports.Comment = mongoose.model 'Comment', CommentSchema