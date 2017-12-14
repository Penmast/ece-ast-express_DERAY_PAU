express = require 'express'
bodyparser = require 'body-parser'

metrics = require './metrics'
user = require './user'
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
app.use bodyparser.urlencoded()

#app.use logging_middleware


app.use '/', express.static "#{__dirname}/../public"

app.get '/', (req, res) ->
  res.render 'index',
    text: "Hello world !"

app.get '/hello/:name', (req, res) ->
  res.send "Hello #{req.params.name}"

app.get '/metrics.json', (req, res) ->
  metrics.get "1337", (err, data) ->
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

app.get '/login', (req, res) ->
  res.render 'login'

app.post 'login', (req, res) ->
  user.get req.body.username, (err, data) ->
    return next err if err
    unless req.session.username == data.username
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
    else res.status(200).send()

app.get '/user.json', (req, res) ->
  user.get "john", (err, data) ->
    if err
      console.log err
      res.status(500).send()
    else res.status(200).json data

app.delete '/user.json/:username', (req, res) ->
  user.remove req.params.username, (err) ->
    if err
      console.log err
      res.status(500).send()
    else res.status(200).send()

app.get '/populate', (req, res) ->
  populate()
  res.redirect '/'

populate = () ->

  metrics.save "1337", [
    timestamp:(new Date '2015-11-04 14:00 UTC').getTime(), value:45
  ,
    timestamp:(new Date '2015-11-04 14:10 UTC').getTime(), value:46
  ], (err) ->
    throw err if err
    console.log "population terminated !"

server.listen app.get('port'), () ->
  console.log "Server listening on #{app.get 'port'} !"
