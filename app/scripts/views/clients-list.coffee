'use strict';

class MetaDash.Views.ClientsListView extends Backbone.View
  template: MetaDash.JST['client-list']

  # clients:
  #   "click .client": "showDetails"

  initialize: (options)->
    @filter = options.filter
    @collection.on('sync', this.render, this)
    @collection.on('silencing', this.render, this)
    @collection.server.checks.on('sync', this.render, this)
    @collection.server.events.on('sync', this.render, this)

  render: ->
    clients = _.map(@collection.queryFilter(@filter), (client) -> client.toJSON({helperAttributes: true}))
    html = @template({ clients: clients })
    this.$el.html(html);

  # showDetails: (evt) ->
  #   client = @collection.findWhere({id: $(evt.currentTarget).data('id')})
  #   if client
  #     event = client.getEvents()
  #     check = client.getChecks()
  #     view = MetaDash.VM.create( this, 'ClientModal', MetaDash.Views.ClientModalView, {client: client, events: events, checks: checks})
  #     view.render()
