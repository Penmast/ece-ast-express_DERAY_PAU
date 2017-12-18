should = require 'should'
user = require '../src/user.coffee'

describe 'user', () ->
  it 'saves properly', (done) ->
    user.save "ok",  "pwd", (err) ->
      should.not.exist err
      done()

  it 'doesn\'t save because missing parameter', (done) ->
    user.save "only name", (err) ->
      should.exist err
      done()

  it 'get', (done) ->
    # do something
    done()
