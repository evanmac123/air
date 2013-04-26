matchFound = (elements) -> elements.size() > 0

encloserMatchingId = (selectors, enclosed) ->
  foundSelector = _.find(selectors, (selector) -> matchFound(enclosed.parents(selector)))
  if foundSelector
    enclosed.parents(foundSelector).attr('id')
  else
    undefined

$('form input[type=text], form textarea').focus(
  (event) ->
    field = $(this)

    enclosingDivId = encloserMatchingId(['.slide', '#request_demo', '#get_started_form'], field)
    fieldId = field.attr('id')

    mpq.track('marketing form field focused', {fieldId: fieldId, enclosingDivId: enclosingDivId})
)
