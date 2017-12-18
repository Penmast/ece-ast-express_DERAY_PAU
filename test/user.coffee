should = require 'should'
user = require '../src/user.coffee'

describe 'user', () ->
  it 'saves properly', (done) ->
    user.save "username", "password", "name", "email", (err) ->
      should.not.exist err
      done()

  it 'doesn\'t save because missing parameter', (done) ->
    user.save "only name", (err) ->
      should.exist err
      done()

  it 'doesn\'t delete because missing parameter', (done) ->
    user.remove (err) ->
      should.exist err
      done()

  it 'gets a existing user', (done) ->
    user.get 'user1', (err) ->
      should.not.exist err
      done()
