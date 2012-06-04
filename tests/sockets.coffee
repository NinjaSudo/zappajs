zappa = require '../src/zappa'
port = 15700

@tests =
  connects: (t) ->
    t.expect 1
    t.wait 3000
    
    zapp = zappa port++, ->
      @on connection: ->
        t.reached 1

    c = t.client(zapp.app)
    c.connect()

  'server emits': (t) ->
    t.expect 1
    t.wait 3000
    
    zapp = zappa port++, ->
      @on connection: ->
        @emit 'welcome'

    c = t.client(zapp.app)
    c.connect()

    c.on 'welcome', ->
      t.reached 1

  'server broadcasts': (t) ->
    t.expect 'reached1', 'reached2', 'data1', 'data2'
    t.wait 3000
    
    zapp = zappa port++, ->
      @on shout: ->
        @emit 'shout', @data

    c = t.client(zapp.app)
    c.connect()
    c2 = t.client(zapp.app)
    c2.connect()
    c3 = t.client(zapp.app)
    c3.connect()

    c.on 'shout', (data) ->
      t.reached 'reached1'
      t.equal 'data1', data.foo, 'bar'

    # FIXME c2 should not be receiving messages!
    c2.on 'shout', (data) ->
      t.reached 'reached2'
      t.equal 'data2', data.foo, 'bar'

    c.emit 'shout', foo: 'bar'

  'server ack': (t) ->
    t.expect 'got-foo', 'acked', 'data'
    t.wait 3000

    zapp = zappa port++, ->
      @on foo: ->
        t.reached 'got-foo'
        @ack foo:'bar'

    c = t.client(zapp.app)
    c.connect()

    c.emit 'foo', bar:'foo', (data) ->
      t.reached 'acked'
      t.equal 'data', data.foo, 'bar'

  'server join': ->

  'server leave': ->
