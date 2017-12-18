level = require 'level'
levelws = require 'level-ws'

db = levelws level "#{__dirname}/../db"

module.exports =
  # get(id, callback)
  # Get metrics
  # - id: metric's id, optional, if none all metrics are retrieved
  # - callback: the callback function, callback(err, data)
  get: (id, callback) ->
    if callback == undefined
      callback = id
      id = null
    values = []
    opts = {}
    if id != null then opts =
        gt: "metrics:#{id}:"
        lt: "metrics:#{ parseInt( id, 10 ) + 1}:"
    rs = db.createReadStream(opts)
      .on 'data', (data) ->
        [ _, id, timestamp ] = data.key.split ":"
        values.push
          timestamp: timestamp
          value: data.value
      .on 'error', (err) ->
        console.log "error"
        callback err
      .on 'close', () ->
        console.log "closing"
        callback null, values

  # save(id, metrics, callback)
  # Save given metrics
  # - id: metric id
  # - metrics: an array of { timestamp, value }
  # - callback: the callback function
  save: (id, metrics, callback) ->
    ws = db.createWriteStream()
    ws.on 'error', callback
    ws.on 'close', callback
    for metric in metrics
      { timestamp, value } =  metric
      ws.write
        key: "metrics:#{id}:#{timestamp}"
        value: value
    ws.end()

  remove: (key, callback) ->
    db.del key, callback
