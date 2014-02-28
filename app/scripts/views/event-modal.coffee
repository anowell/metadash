'use strict';

class MetaDash.Views.EventModalView extends Backbone.View
  template: MetaDash.JST['event-modal']

  tagName: "div"
  className: "modal fade"
  attributes:
    tabindex: "-1"
    role: "dialog"

  events:
    "click .silence": "silence"
    "click .silence-client": "silenceClient"
    "click .unsilence": "unsilence"
    "click .unsilence-check": "unsilenceCheck"
    "click .unsilence-client": "unsilenceClient"

  initialize: (options) ->
    @event = options.event
    @client = options.client
    @check = options.check

    @$el.on("hidden.bs.modal", => @remove())

    @event.on('change', this.update, this)
    @client.on('change', this.update, this)

    # Strangely: keepalive doesn't have a check
    @check?.on('change', this.update, this)

  render: ->
    @update()
    @$el.appendTo("body")
    @$el.modal("show")

  update: ->
    console.log(@check?.toJSON() ? (new MetaDash.Models.Check).toJSON())
    html = @template(
      {
        event: @event?.toJSON({helperAttributes: true}) ? (new MetaDash.Models.Event).toJSON({helperAttributes: true}),
        client: @client?.toJSON() ? (new MetaDash.Models.Client).toJSON(),
        check: @check?.toJSON() ? (new MetaDash.Models.Check).toJSON()
      }
    )
    @$el.html(html);

  remove: ->
    @$el.modal("hide")
    super

  silence: (evt, model=@event) ->
    @remove
    btn = $(evt.currentTarget)
    btn.button('loading')
    expire = btn.data('expire')
    model.silence(
      expire: expire
      success: (model) =>
        @update()
        console.log("Silenced #{model.get('id')}")
      error: (model) =>
        @update()
        console.log("Failed to unsilence #{model.get('id')}")
    )

  unsilence: (evt, model=@event) ->
    @remove
    $(evt.currentTarget).button('loading')
    model.unsilence(
      success: (model) =>
        @update()
        console.log("Unsilenced #{model.get('id')}")
      error: (model) =>
        @update()
        console.log("Failed to unsilence #{model.get('id')}")
    )

  silenceClient: (evt) -> @silence(evt, @client)
  unsilenceClient: (evt) -> @unsilence(evt, @client)
  unsilenceCheck: (evt) -> $(evt.currentTarget).button('loading')  #@unsilence(evt, @check)
