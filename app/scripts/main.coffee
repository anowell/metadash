window.MetaDash =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  VM: {}
  SensuServers: window.sensu.servers ? []
  Links: window.sensu.links ? {}
  init: ->
    'use strict'
    console.log 'Initializing MetaDash...'
    for server in this.SensuServers
      options = {slug: server.slug, server: server}
      server.clients = new MetaDash.Collections.Clients(null, options)
      server.events = new MetaDash.Collections.Events(null, options)
      server.stashes = new MetaDash.Collections.Stashes(null, options)
      server.checks = new MetaDash.Collections.Checks(null, options)

  fetchHandlers:
    error: (collection, response, options) ->
      collection.fetchesFailed += 1
      console.log("Error fetching #{collection.url}: #{collection.fetchesFailed} consecutive fails")
      setTimeout( -> 
        console.log("Retrying #{collection.url}")
        collection.fetch(MetaDash.fetchHandlers)
      , collection.refreshInterval*1000)

    success: (collection, response, options) ->
      console.log("Updated #{collection.url}: #{collection.length} items")
      collection.fetchesFailed = 0
      setTimeout( -> 
        collection.fetch(MetaDash.fetchHandlers)
      , collection.refreshInterval*1000)

  beginSync: (options) ->
    console.log("Initial sync of all collections")
    for server in this.SensuServers
      server.events.fetch(@fetchHandlers)
      server.clients.fetch(@fetchHandlers)
      server.stashes.fetch(@fetchHandlers)
      server.checks.fetch(@fetchHandlers)


# All navigation that is relative should be processed by the router.
$(document).on("click", "a[href]", (evt) ->
  href = { prop: $(this).prop("href"), attr: $(this).attr("href") }
  root = location.protocol + "//" + location.host + "/";

  # Ensure the root is part of the anchor href, meaning it's relative.
  if href.prop.slice(0, root.length) == root
    evt.preventDefault();
    Backbone.history.navigate(href.attr, true) unless href.attr == '#'
)

$ ->
  'use strict'
  MetaDash.init()
  MetaDash.beginSync()
  MetaDash.router = new MetaDash.Routers.SensuRouter()