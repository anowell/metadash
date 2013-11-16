'use strict';

class MetaDash.Models.Stash extends MetaDash.Models.SensuBaseModel
  defaults:
    path: "silence"
    content: {}
    expire: null

  idAttribute: "path"

  isNew: ->
    !@collection?.server?.stashes.findWhere({path: this.get('path')})

  # sync: (method, model, options) =>
  #   options ||= {}
  #   if method == "delete"
  #     options.url = "#{SensuDashboard.Stashes.url}/#{model.get("path")}"
  #   Backbone.sync(method, model, options)

  # remove: (options = {}) =>
  #   @successCallback = options.success
  #   @errorCallback = options.error
  #   @destroy
  #     wait: true
  #     success: (model, response, opts) =>
  #       @successCallback.apply(this, [model, response, opts]) if @successCallback
  #     error: (model, xhr, opts) =>
  #       @errorCallback.apply(this, [model, xhr, opts]) if @errorCallback


class MetaDash.Collections.Stashes extends MetaDash.Collections.SensuBaseCollection
  model: MetaDash.Models.Stash
  initialize: (models, options) ->
    super(models, options)
    this.url = '/' + options.slug + '/stashes'
