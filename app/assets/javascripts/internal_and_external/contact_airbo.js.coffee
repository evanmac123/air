contactAirboId = ->
  '#contact-airbo'

contactAirboPing = ->
  $.post "/ping",
    event: 'Explore page - Interaction', 
    properties:
      action: 'Clicked "Contact Airbo" button'

window.contactAirbo = ->
  $ ->
    bindIntercomOpen contactAirboId()

  $(contactAirboId()).click (e) ->
    e.preventDefault()
    contactAirboPing()