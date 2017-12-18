should = require 'should'
usermetrics = require '../src/usermetrics.coffee'

describe 'usermetrics', () ->
  it 'saves properly', (done) ->
    usermetrics.save "username", 66, (err) ->
      should.not.exist err
      done()

  it 'deletes properly', (done) ->
    usermetrics.remove 'username', (err) ->
      should.not.exist err
      done()

  it 'gets existing user\'s usermetrics', (done) ->
    usermetrics.get 'user1', (err) ->
      should.not.exist err
      done()
