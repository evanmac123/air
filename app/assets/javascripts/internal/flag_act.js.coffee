root = exports ? this

root.connectFlagLink = (linkDOMId, actId, suspectedUserId) ->
  $('#' + linkDOMId).click (e)->
    e.preventDefault()
    $(this).text("Flagged")
    $.post('/ping', {event: 'flagged act', properties: {act_id: actId, suspect_id: suspectedUserId}})
