'use strict';

class MetaDash.Views.EventsListView extends Backbone.View
  template: MetaDash.JST['event-list']
  
  initialize: (options)->
    @filter = options.filter
    this.collection.on('add', this.render, this)
    this.collection.on('remove', this.render, this)
    this.collection.on('reset', this.render, this)

  filterEvents: ->
    @collection.chain()
      .filter (event) =>
        toArray = (val) ->
          return val if _.isArray(val)
          return [val] if _.isString(val)
          return []
        anyMatchCheck = (param, check) ->
          _.any(toArray(param), (p) -> check.match(new RegExp(p)))
        anyMatchStatus = (param, status) ->
          _.any(toArray(param), (p) -> parseInt(p) == status)

        f = @filter
        if f.silenced?
          return false unless (f.silenced!="0") == event.silenced()
        if f.status?
          return false unless anyMatchStatus(toArray(f.status), event.get('status'))
        if f.filter?
          return false unless anyMatchCheck(toArray(f.filter), event.get('check'))
        if f.ignore?
          return false if anyMatchCheck(toArray(f.ignore), event.get('check'))
        return true
      .map (event) ->
        {
          client: event.get('client')
          check: event.get('check')
          output: event.get('output')
          statusName: event.statusName()
        }
      .value()

  render: ->
    events = @filterEvents()
    html = @template({ events: events })
    this.$el.html(html);
