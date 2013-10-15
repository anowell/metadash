'use strict';

class MetaDash.Models.Check extends MetaDash.Models.SensuBaseModel
  defaults:
    handlers: ["default"]
    standalone: false
    subscribers: []
    interval: 60



class MetaDash.Collections.Checks extends MetaDash.Collections.SensuBaseCollection
  model: MetaDash.Models.Check
  initialize: (models, options) ->
    super(models, options)
    this.url = '/' + options.slug + '/checks'