level = require 'level'
levelws = require 'level-ws'

db = levelws level "#{__dirname}/../db/user"

module.exports =
  get: (username, callback) ->
    user = {}
    #gte: "user:#{username}"

    rs = db.createReadStream()
      .on 'data', (data) ->
        console.log 'data: ' + data.value
        user = data.value


      .on 'error', callback

      .on 'close', ->
        console.log 'closing'
        callback null, user

  save: (username, password, name, email, callback) ->
    ws = db.createWriteStream()
    ws.on 'error', callback
    ws.on 'close', callback
    console.log username + " " + password + " " + name + " " + email
    user =
      username: username
      password: password
      name: name
      email: email
    ws.write
      key: username
      value: user
      valueEncoding : 'json'
    ws.end()

  remove: (username, callback) ->
    console.log "deleting user " + username
    db.del username, callback


  # We won't do update
