level = require 'level'
levelws = require 'level-ws'
metrics = require './metrics'
user = require './user'

db = levelws level "#{__dirname}/../db/usermetrics"

module.exports =
  get: (username, id, callback) ->
    userid = {}
    if callback == undefined
      callback = id
      id = null

    if id == null then opts =
      gte: "userid:#{username}:0"
      lte: "userid:#{username}:9999"

    else opts =
      gte: "userid:#{username}:#{id}"
      lte: "userid:#{username}:#{id}"

    rs = db.createReadStream(opts)
    rs.on 'data', (data) ->
        value = JSON.parse data.value
        console.log value
        userid = value


    rs.on 'error', callback

    rs.on 'close', ->
        console.log 'closing'
        callback null, userid

  save: (username, id, callback) ->
    ws = db.createWriteStream()
    ws.on 'error', callback
    ws.on 'close', callback
    ws.write
      key:"userid:#{username}:#{id}"
      value:
        username: username
        id: id
      valueEncoding: 'json'
    ws.end()


  remove: (username, callback) ->

  # We won't do update
