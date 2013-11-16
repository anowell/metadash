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
    "click .unsilence": "unsilence"
    # "click .unsilence-check": "unsilence"
    # "click .unsilence-client": "unsilence"

  initialize: (options) ->
    @event = options.event
    @client = options.client
    @check = options.check

    @$el.on("hidden.bs.modal", => @remove())

    @event.on('change', this.update, this)
    @client.on('change', this.update, this)
    @check.on('change', this.update, this)

  render: ->
    @update()
    @$el.appendTo("body")
    @$el.modal("show")

  update: ->
    html = @template(
      {
        event: @event?.toJSON({helperAttributes: true}) ? {}
        client: @client?.toJSON() ? {}
        check: @check?.toJSON() ? {}
      }
    )
    @$el.html(html);

  remove: ->
    @$el.modal("hide")
    super

  silence: (evt) ->
    @remove
    expire = $(evt.currentTarget).data('expire')
    @event.silence(
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
    model.unsilence(
      success: (model) =>
        @update()
        console.log("Unsilenced #{model.get('id')}")
      error: (model) =>
        @update()
        console.log("Failed to unsilence #{model.get('id')}")
    )

  # unsilenceClient: (evt) -> unsilence(evt, @client)
  # unsilenceCheck: (evt) -> unsilence(evt, @check)
