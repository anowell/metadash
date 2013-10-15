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
      client_silence_path: "silence/#{@get("client")}"
      silence_path: "silence/#{@get("id")}"
    
    @listenTo(@getServer().stashes, "reset", @setSilencing)
    @listenTo(@getServer().stashes, "add", @setSilencing)
    @listenTo(@getServer().stashes, "remove", @setSilencing)
    @setSilencing()

  setSilencing: ->
    check_silenced = false
    client_silenced = false
    check_silenced = true if @getServer().stashes.get(@get("silence_path"))
    client_silenced = true if @getServer().stashes.get(@get("client_silence_path"))

    if @get("check_silenced") != check_silenced || @get("client_silenced") != client_silenced
      @set
        check_silenced: check_silenced
        client_silenced: client_silenced

  silenced: ->
    @get("check_silenced") || @get("client_silenced")

  statusName:  ->
    switch @get("status")
      when 1 then "warning"
      when 2 then "critical"
      else "unknown"

  # resolve: (options = {}) =>
  #   @successCallback = options.success
  #   @errorCallback = options.error
  #   @destroy
  #     success: (model, response, opts) =>
  #       @successCallback.apply(this, [model, response, opts]) if @successCallback
  #     error: (model, xhr, opts) =>
  #       @errorCallback.apply(this, [model, xhr, opts]) if @errorCallback

  # silence: (options = {}) =>
  #   @successCallback = options.success
  #   @errorCallback = options.error
  #   stash = SensuDashboard.Stashes.create({
  #     path: @get("silence_path")
  #     content: { timestamp: Math.round(new Date().getTime() / 1000) }}, {
  #     success: (model, response, opts) =>
  #       @successCallback.apply(this, [this, response]) if @successCallback
  #     error: (model, xhr, opts) =>
  #       @errorCallback.apply(this, [this, xhr, opts]) if @errorCallback})

  # unsilence: (options = {}) =>
  #   @successCallback = options.success
  #   @errorCallback = options.error
  #   stash = SensuDashboard.Stashes.get(@get("silence_path"))
  #   if stash
  #     stash.destroy
  #       success: (model, response, opts) =>
  #         @successCallback.apply(this, [this, response, opts]) if @successCallback
  #       error: (model, xhr, opts) =>
  #         @errorCallback.apply(this, [this, xhr, opts]) if @errorCallback
  #   else
  #     @errorCallback.apply(this, [this]) if @errorCallback


class MetaDash.Collections.Events extends MetaDash.Collections.SensuBaseCollection
  model: MetaDash.Models.Event
  comparator: (event) ->
    (3-(event.get('status'))).toString() + event.get('client')

  initialize: (models, options) ->
    super(models, options)
    @url = '/' + options.slug + '/events'

  refreshInterval: 30



