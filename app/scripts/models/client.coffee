'use strict';

class MetaDash.Models.Client extends MetaDash.Models.SensuBaseModel
  defaults:
    name: null
    address: null
    subscriptions: []
    timestamp: 0

  idAttribute: "name"

  initialize: ->
    @set(silence_path: "silence/#{@get("name")}")
    @listenTo(@getServer().stashes, "reset", @setSilencing)
    @listenTo(@getServer().stashes, "add", @setSilencing)
    @listenTo(@getServer().stashes, "remove", @setSilencing)
    @setSilencing()

  getEvents: ->
    @getServer().events.filter( (event) =>
      @get("name") == event.get("client")
    )

  getChecks: ->
    @getServer().checks.filter( (check) =>
      _.intersection(@get("subscriptions"), check.get("subscribers")).length > 0
    )

  setSilencing: ->
    silenced = false
    silenced = true if @getServer().stashes.get(@get("silence_path"))
    if @get("silenced") != silenced
      @set(silenced: silenced)

  silence: (options = {}) =>
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

  unsilence: (options = {}) =>
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

  toJSON: (options) ->
    json = _.clone(this.attributes)

    if options?.helperAttributes?
      checks = @getChecks().map (c) ->
        { name: c.get("name"), statusName: "ok" }

      # Until I come up with a better idea: hard-code the default keepalive
      checks.push({name: "keepalive", statusName: "ok"})

      for e in @getEvents()
        for check in checks
            check.statusName = e.getStatusName() if check.name == e.get("check")
      json.checks = checks

    json

  # remove: (options = {}) =>
  #   @successCallback = options.success
  #   @errorCallback = options.error
  #   @destroy
  #     wait: true
  #     success: (model, response, opts) =>
  #       @successCallback.apply(this, [model, response, opts]) if @successCallback
  #     error: (model, xhr, opts) =>
  #       @errorCallback.apply(this, [model, xhr, opts]) if @errorCallback


class MetaDash.Collections.Clients extends MetaDash.Collections.SensuBaseCollection
  model: MetaDash.Models.Client
  initialize: (models, options) ->
    super(models, options)
    this.url = '/' + options.slug + '/clients'

  comparator: 'name'

  queryFilter: (f) ->
    @.filter (client) =>
        toArray = (val) ->
          return val if _.isArray(val)
          return [val] if _.isString(val)
          return []
        anyMatchSubscription = (param, subscriptions) ->
          _.intersection(toArray(param), subscriptions).length > 0
        anyMatchStatus = (param, status) ->
          _.any(toArray(param), (p) -> parseInt(p) == status)

        if f.silenced?
          return false unless (f.silenced!="0") == client.isSilenced()
        # if f.status?
        #   return false unless anyMatchStatus(toArray(f.status), client.get('status'))
        if f.filter?
          return false unless anyMatchSubscription(toArray(f.filter), client.get('subscriptions'))
        if f.ignore?
          return false if anyMatchSubscription(toArray(f.ignore), client.get('subscriptions'))
        return true
