mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId

mongoose.connect 'mongodb://localhost/friends_test'

ItemSchema = new mongoose.Schema
  name: String
  type: String
  value: Number
  info: ObjectId

ItemWeaponSchema = new mongoose.Schema
  type: String
  minDamage: Number
  maxDamage: Number

CharacterSchema = new mongoose.Schema
  name: String
  maxStats:
    health: Number
    mana: Number
  stats:
    health: Number
    mana: Number
  inventory: [ItemSchema]
  equip:
    head: { type: ObjectId, ref: 'Item' }
    body: { type: ObjectId, ref: 'Item' }
    feet: { type: ObjectId, ref: 'Item' }
    left: { type: ObjectId, ref: 'Item' }
    right: { type: ObjectId, ref: 'Item' }
  
exports.Item = mongoose.model 'Item', ItemSchema
exports.ItemWeaponSchema = mongoose.model 'ItemWeapon', ItemWeaponSchema
exports.Character = mongoose.model 'Character', CharacterSchema