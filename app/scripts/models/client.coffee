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

