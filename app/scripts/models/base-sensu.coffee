'use strict';

class MetaDash.Models.SensuBaseModel extends Backbone.Model
  getServer: -> @collection.server

  create: (attributes, options) ->
    options ||= {}
    options.wait = true
    Backbone.Model.prototype.create.call(this, attributes, options)

  destroy: (attributes, options) ->
    options ||= {}
    options.wait = true
    Backbone.Model.prototype.destroy.call(this, attributes, options)


class MetaDash.Collections.SensuBaseCollection extends Backbone.Collection
  initialize: (models, options) ->
    @server = options.server
    @fetchesFailed = 0

  refreshInterval: 60

  create: (attributes, options) ->
    options ||= {}
    options.wait = true
    Backbone.Collection.prototype.create.call(this, attributes, options)