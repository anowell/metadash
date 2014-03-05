'use strict';

class MetaDash.Views.ClientsDashView extends Backbone.View
  template: MetaDash.JST['client-dash']
  el: "#main"

  initialize: (options)->
    @filter = options.filter
    @links = MetaDash.Links.clients ? []
    @servers = _.chain(MetaDash.SensuServers)
      .map (server) ->
        lastSync =
        {
          slug: server.slug
          host: server.host
          lastSync: server.clients?.lastSync?.toLocaleTimeString() ? "fetching..."
        }
      .filter( (server) =>
        return true unless @filter.env
        return true if server.slug == @filter.env
        return true if _.isArray(@filter.env) && _.contains(@filter.env, server.slug)
        return false
      ).value()

    _.each MetaDash.SensuServers, (server) =>
      server.clients.on('sync', this.updateLastSyncTime, this )

  render: ->
    html = @template({ servers: @servers, links: @links, query: window.location.search})
    this.$el.html(html);

    for server in MetaDash.SensuServers
      view = MetaDash.VM.create(
        this,
        'ClientList-'+server.slug,
        MetaDash.Views.ClientsListView,
        {collection: server.clients, filter: @filter, el: "#clients-#{server.slug}"})
      view.render()

    this # maintains chainability

  updateLastSyncTime: (collection, resp, options) ->
    collection.lastSync = new Date
    time = collection.lastSync.toLocaleTimeString()
    $("#server-group-#{collection.server.slug} .sync-status").html("#{time}")