'use strict';

class MetaDash.Models.SensuBaseModel extends Backbone.Model
  getServer: -> @collection.server

class MetaDash.Collections.SensuBaseCollection extends Backbone.Collection
  initialize: (models, options) ->
    @server = options.server
    @fetchesFailed = 0

  refreshInterval: 60

