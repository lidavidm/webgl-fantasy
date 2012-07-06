#!/bin/sh

#mongod --logpath mongo.log --dbpath db --bind_ip 127.0.0.1 &
nodemon -w app.coffee -w models.coffee -w routes/ app.coffee
