bindShowMoreTilesLink = (moreTilesSelector, tileSelector, spinnerSelector, targetSelector) ->
  $(moreTilesSelector).live('click', (event) ->
    event.preventDefault()

    if($(this).attr('disabled') != 'disabled')
      $(spinnerSelector).show()

      baseBatchSize = $(tileSelector).length

      $.get(
        $(this).data('tile-path'),
        {base_batch_size: baseBatchSize, partial_only: 'true'},
        ((data) -> $(targetSelector).replaceWith(data)))
  )

window.bindShowMoreTilesLink = bindShowMoreTilesLink
