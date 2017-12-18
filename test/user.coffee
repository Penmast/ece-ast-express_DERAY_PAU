should = require 'should'
user = require '../src/user.coffee'

describe 'user', () ->
  it 'saves properly', (done) ->
    user.save "username", "password", "name", "email", (err) ->
      should.not.exist err
      done()

  it 'deletes properly', (done) ->
    user.save "username", "password", "name", "email"
    user.remove 'username', (err) ->
      should.not.exist err
      done()

  it 'gets a existing user', (done) ->
    user.get 'user1', (err) ->
      should.not.exist err
      done()
