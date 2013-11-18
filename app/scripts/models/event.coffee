'use strict';

class MetaDash.Models.Event extends MetaDash.Models.SensuBaseModel
  defaults:
    client: null
    check: null
    occurrences: 0
    output: null
    status: 3
    flapping: false
    issued: "0000-00-00T00:00:00Z"

  initialize: ->
    @set id: "#{@get("client")}/#{@get("check")}"
    @set
      client_silence_path: "silence/#{@get('client')}"
      silence_path: "silence/#{@get('id')}"
      check_silence_path: "silence/all/#{@get('check')}"

    @listenTo(@getServer().stashes, "reset", @setSilencing)
    @listenTo(@getServer().stashes, "add", @setSilencing)
    @listenTo(@getServer().stashes, "remove", @setSilencing)
    @setSilencing()

  setSilencing: ->
    check_silenced = false
    client_silenced = false
    event_silenced = true if @getServer().stashes.get(@get("silence_path"))
    check_silenced = true if @getServer().stashes.get(@get("check_silence_path"))
    client_silenced = true if @getServer().stashes.get(@get("client_silence_path"))

    if @get("event_silenced") != event_silenced || @get("client_silenced") != client_silenced || @get("check_silenced") != check_silenced
      @set
        event_silenced: event_silenced
        check_silenced: check_silenced
        client_silenced: client_silenced
      @trigger('silencing', this)

  isSilenced: ->
    @get("event_silenced") || @get("client_silenced") || @get("check_silenced")

  getStatusName:  ->
    switch @get("status")
      when 1 then "warning"
      when 2 then "critical"
      else "unknown"

  getIssuedTime: ->
    new Date(@get('issued') * 1000)

  getClient: ->
    @getServer().clients.findWhere({name: @get('client')})

  getCheck: ->
    @getServer().checks.findWhere({name: @get('check')})

  # getStashes: ->
  #   @getServer().stashes.filter( (s) =>
  #     path = s.get('path')
  #     path == @get('silence_path') or path == @get('client_silence_path') or path == @get('check_silence_path')
  #   )

  toJSON: (options) ->
    json = _.clone(this.attributes)

    if options?.helperAttributes?
      json.statusName = @getStatusName()
      json.silenced = @isSilenced()
      json.issuedTime = @getIssuedTime()

    json

  # resolve: (options = {}) =>
  #   @successCallback = options.success
  #   @errorCallback = options.error
  #   @destroy
  #     success: (model, response, opts) =>
  #       @successCallback.apply(this, [model, response, opts]) if @successCallback
  #     error: (model, xhr, opts) =>
  #       @errorCallback.apply(this, [model, xhr, opts]) if @errorCallback

  silence: (options = {}) ->
    @successCallback = options.success
    @errorCallback = options.error

    stash = @getServer().stashes.create({
      path: @get("silence_path")
      expire: options?.expire
      content:
        timestamp: Math.round(new Date().getTime() / 1000)
        description: "Silenced by MetaDash" + (if options?.expire then "for #{options.expire/60} minutes." else "indefinitely.")
    }, {
      success: (model, response, opts) =>
        @successCallback.apply(this, [this, response]) if @successCallback
      error: (model, xhr, opts) =>
        @errorCallback.apply(this, [this, xhr, opts]) if @errorCallback
    })

  unsilence: (options = {}) ->
    @successCallback = options.success
    @errorCallback = options.error
    stash = @getServer().stashes.get(@get("silence_path"))
    if stash
      stash.destroy
        success: (model, response, opts) =>
          @successCallback.apply(this, [this, response, opts]) if @successCallback
        error: (model, xhr, opts) =>
          @errorCallback.apply(this, [this, xhr, opts]) if @errorCallback
    else
      @errorCallback.apply(this, [this]) if @errorCallback


class MetaDash.Collections.Events extends MetaDash.Collections.SensuBaseCollection
  model: MetaDash.Models.Event
  comparator: (event) ->
    (3-(event.get('status'))).toString() + event.get('client')

  initialize: (models, options) ->
    super(models, options)
    @url = '/' + options.slug + '/events'

  refreshInterval: 30

  queryFilter: (f) ->
    @.filter (event) =>
        toArray = (val) ->
          return val if _.isArray(val)
          return [val] if _.isString(val)
          return []
        anyMatchCheck = (param, check) ->
          _.any(toArray(param), (p) -> check.match(new RegExp(p)))
        anyMatchStatus = (param, status) ->
          _.any(toArray(param), (p) -> parseInt(p) == status)

        if f.silenced?
          return false unless (f.silenced!="0") == event.isSilenced()
        if f.status?
          return false unless anyMatchStatus(toArray(f.status), event.get('status'))
        if f.filter?
          return false unless anyMatchCheck(toArray(f.filter), event.get('check'))
        if f.ignore?
          return false if anyMatchCheck(toArray(f.ignore), event.get('check'))
        return true
