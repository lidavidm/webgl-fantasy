mongoose = require 'mongoose'

mongoose.connect 'mongodb://localhost/friends_test'

ItemSchema = new mongoose.Schema
  name: String
  type: String

CharacterSchema = new mongoose.Schema
  name: String
  stats:
    health: Number
    mana: Number
  inventory: [ItemSchema]
  
exports.Item = mongoose.model 'Item', ItemSchema
exports.Character = mongoose.model 'Character', CharacterSchema