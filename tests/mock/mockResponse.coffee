
class MockResponse
  constructor: ->
    @headers = {}

  status: (code) ->
    @statusCode = code
    return this

  type : (type) ->
    @set 'Content-Type', type
    type

  contentType : (type) ->
    @type type

  send: (body) ->
    # allow status / body
    if 2 == arguments.length
      if ('number' != typeof body && 'number' == typeof arguments[1])
        @statusCode = arguments[1]
      else
        @statusCode = body
        body = arguments[1]

    switch typeof body
      # response status
      when 'number'
        @get('Content-Type') || @type('txt')
        @statusCode = body
        body = http.STATUS_CODES[body]
      # string defaulting to html
      when 'string'
        unless @get 'Content-Type'
          @charset = @charset || 'utf-8'
          @type('html')
      when 'boolean', 'object'
        unless body?
          body = ''
        else if Buffer.isBuffer body
          @get('Content-Type') || @type('bin')
        else
          return @json body

    # respond
    @end body
    return this

  json : (obj) ->
    # allow status / body
    if 2 == arguments.length
      # res.json(body, status) backwards compat
      if 'number' == typeof arguments[1]
        @statusCode = arguments[1]
      else
        @statusCode = obj
        obj = arguments[1]

    body = JSON.stringify obj

    # content-type
    @charset = @charset || 'utf-8'
    @get('Content-Type') || @set('Content-Type', 'application/json')
    
    return @send body


  set : (field, val) ->
    @header field, val

  header : (field, val) ->
    if (2 == arguments.length)
      @headers[field] = '' + val
    else
      for key, value of field
        @headers[key] = '' + value
    return this

  get : (field) ->
    @headers[field]

  end: (body) ->
    @statusCode ?= 200
    @_body = body
    @onEnd body

  onEnd: (body) ->
    #OVERRIDE THIS

module.exports = MockResponse
