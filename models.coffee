mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId

mongoose.connect 'mongodb://localhost/friends_test'

ItemRef = String

CharacterSchema = new mongoose.Schema
  name: String
  maxStats:
    health: Number
    mana: Number
  stats:
    health: Number
    mana: Number
  inventory: [ItemRef]
  equip:
    head: ItemRef
    body: ItemRef
    feet: ItemRef
    left: ItemRef
    right: ItemRef

exports.Character = mongoose.model 'Character', CharacterSchema