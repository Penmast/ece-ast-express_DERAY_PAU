express = require 'express'
bodyparser = require 'body-parser'

metrics = require './metrics'
user = require './user'
usermetrics = require './usermetrics'
app = express()
morgan = require 'morgan' 

server = require('http').Server(app)
io = require('socket.io')(server)

session = require 'express-session'
LevelStore = require('level-session-store')(session)

app.use morgan 'dev'

sockets = []

io.on 'connection', (socket) ->
  sockets.push socket

app.use session
  secret: 'MyAppSecret'
  store: new LevelStore './db/sessions'
  resave: true
  saveUninitialized: true

###logging_middleware = (req, res, next) ->
  #for socket, i in socket
  io.emit 'logs',
    username: if req.session.loggedIn then req.session.username else 'anonymous'
    url : req.url
  next()
###

app.set 'port', '8888'
app.set 'views', "#{__dirname}/../views"
app.set 'view engine', 'pug'

app.use bodyparser.json()
app.use bodyparser.urlencoded
  extended: false

#app.use logging_middleware


app.use '/', express.static "#{__dirname}/../public"

###app.get '/', (req, res) ->
  res.render 'index',
    text: "Hello world !"

app.get '/hello/:name', (req, res) ->
  res.send "Hello #{req.params.name}"###

###app.get '/metrics.json', (req, res) ->
  metrics.get (err, data) ->
    if err
      console.log err
      res.status(500).send()
    else res.status(200).json data
    ###

app.get '/metrics.json/:id', (req, res) ->
  metrics.get req.params.id, (err, data) ->
    if err
      console.log err
      res.status(500).send()
    else res.status(200).json data

app.post '/metrics.json/:id', (req, res) ->
  metrics.save req.params.id, req.body, (err) ->
    if err
      console.log err
      res.status(500).send()
    else res.status(200).send()

app.delete '/metrics.json/:id', (req, res) ->
  metrics.get req.params.id, (err, data) ->
    for d in data
      metrics.remove "metrics:#{req.params.id}:#{d.timestamp}", (err) ->
        if err
          console.log err
          res.status(500).send()
        else res.status(200).send()

app.get '/login', (req, res) ->
  res.render 'login'

app.post '/login', (req, res) ->
  user.get req.body.username, (err, data) ->
    return next err if err
    unless req.body.password == data.password
      res.redirect '/login'
    else
      req.session.loggedIn = true
      req.session.username = data.username
      res.redirect '/'

app.get '/logout', (req, res) ->
  delete req.session.loggedIn
  delete req.session.username
  res.redirect '/login'

authCheck = (req, res, next) ->
  unless req.session.loggedIn == true
    res.redirect '/login'
  else
    next()

app.get '/', authCheck, (req, res) ->
  res.render 'index', name: req.session.username

app.post '/user.json', (req, res) ->
  user.save req.body.username, req.body.password, req.body.name, req.body.email, (err) ->
    if err
      console.log err
      res.status(500).send()
    else
      res.status(200).send()

app.get '/user.json', (req, res) ->
  user.get "newmember", (err, data) ->
    if err
      console.log err
      res.status(500).send()
    else
      res.status(200).json data

app.delete '/user.json/:username', (req, res) ->
  user.remove req.params.username, (err) ->
    if err
      console.log err
      res.status(500).send()
    else res.status(200).send()

app.post '/usermetrics.json/:id', (req, res) ->
  usermetrics.save req.session.username, req.params.id, (err) ->
    if err
      console.log err
      res.status(500).send()
    else
      res.status(200).send()

app.post '/usermetrics.json/', (req, res) ->
  usermetrics.save req.body.username, req.body.id, (err) ->
    if err
      console.log err
      res.status(500).send()
    else
      res.status(200).send()

app.get '/usermetrics.json', (req, res) ->
  session_user = req.session.username
  usermetrics.get session_user, (err, data) ->
    if err
      console.log err
      res.status(500).send()
    else
      res.status(200).json data

app.delete '/usermetrics.json', (req, res) ->
  usermetrics.remove req.body.username, req.body.id, (err) ->
    if err
      console.log err
      res.status(500).send()
    else res.status(200).send()

app.get '/signup', (req, res) ->
  res.render 'signup'

app.post '/signup', (req, res) ->
  user.save req.body.username, req.body.password, req.body.name, req.body.email, (err) ->
    if err
      console.log err
      res.status(500).send()
    else
      res.redirect '/login'

app.get '/populate', (req, res) ->
  populate()
  res.redirect '/'

populate = () ->

  metrics.save "1", [
    timestamp:(new Date '2015-11-04 14:00 UTC').getTime(), value:30
  ,
    timestamp:(new Date '2015-11-04 14:10 UTC').getTime(), value:35
  ], (err) ->
    throw err if err

  metrics.save "2", [
    timestamp:(new Date '2016-11-06 11:00 UTC').getTime(), value:20
  ,
    timestamp:(new Date '2017-11-06 14:10 UTC').getTime(), value:21
  ], (err) ->
    throw err if err

  metrics.save "5", [
    timestamp:(new Date '2015-11-04 14:00 UTC').getTime(), value:5
  ,
    timestamp:(new Date '2015-11-04 14:10 UTC').getTime(), value:55
  ], (err) ->
    throw err if err

  metrics.save "8", [
    timestamp:(new Date '2015-05-04 14:00 UTC').getTime(), value:1
  ,
    timestamp:(new Date '2015-06-04 14:10 UTC').getTime(), value:2
  ], (err) ->
    throw err if err

  metrics.save "10", [
    timestamp:(new Date '2017-11-04 14:00 UTC').getTime(), value:99
  ,
    timestamp:(new Date '2017-11-04 14:10 UTC').getTime(), value:99
  ], (err) ->
    throw err if err

  user.save "user1", "password1", "John", "john@gmail.com", (err) ->
    throw err if err

  user.save "user2", "password2", "Max", "max@gmail.com", (err) ->
    throw err if err

  user.save "user3", "password3", "Alice", "alice@gmail.com", (err) ->
    throw err if err

  usermetrics.save "user1", "1", (err) ->
    throw err if err

  usermetrics.save "user1", "2", (err) ->
    throw err if err

  usermetrics.save "user1", "5", (err) ->
    throw err if err

  usermetrics.save "user2", "8", (err) ->
    throw err if err

  usermetrics.save "user2", "10", (err) ->
    throw err if err


server.listen app.get('port'), () ->
  console.log "Server listening on #{app.get 'port'} !"
