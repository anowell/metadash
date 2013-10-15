'use strict';

class MetaDash.Routers.SensuRouter extends Backbone.Router
  routes:
    "":                     "index"
    "events":               "events"
#    "clients(/:name)":        "client"
#    "checks(/:name)":         "checks"
#    "stats":                  "stats"

  initialize: ->
    # start watching for hashchange events
    Backbone.history.start( 
      pushState : true
      root : '/'
    ) 

  index: ->
    defaultRoute = "events" + (MetaDash.Links?.events[0]?.query ? "")
    Backbone.history.navigate(defaultRoute, true)

  events: (params) ->
    filter = params ? {}
    #paramHash = JSON.stringify(params).split("").reduce(((a,b) -> a=((a<<5)-a)+b.charCodeAt(0); a&a),0)
    view = MetaDash.VM.create( {}, 'EventDash', MetaDash.Views.EventsDashView, {filter: filter})
    view.render()

  check: (name, params) ->

  client: (name, params) ->