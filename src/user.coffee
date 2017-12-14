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
        try
          JSON.parse data.value
          console.log "ok"
        catch e
          console.log "pas ok"
          # body...

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
      key: "key:#{username}:#{name}"
      value: user
      valueEncoding : 'json'
    ws.end()

  remove: (username, callback) ->
    # TODO: delete a user by username

  # We won't do update
