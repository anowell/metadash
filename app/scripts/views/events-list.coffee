'use strict';

class MetaDash.Views.EventsListView extends Backbone.View
  template: MetaDash.JST['event-list']

  events:
    "click .event": "showDetails"

  initialize: (options)->
    @filter = options.filter
    @collection.on('add', this.render, this)
    @collection.on('remove', this.render, this)
    @collection.on('reset', this.render, this)
    @collection.on('silencing', this.render, this)

  render: ->
    events = _.map(@collection.queryFilter(@filter), (event) ->
      {
        id: event.get('id')
        client: event.get('client')
        check: event.get('check')
        output: event.get('output')
        statusName: event.getStatusName()
      }
    )
    html = @template({ events: events })
    this.$el.html(html);

  showDetails: (evt) ->
    event = @collection.findWhere({id: $(evt.currentTarget).data('id')})
    client = event.getClient()
    check = event.getCheck()
    view = MetaDash.VM.create( this, 'EventModal', MetaDash.Views.EventModalView, {event: event, client: client, check: check})
    view.render()
