bindShowMoreTilesLink = (moreTilesSelector, tileSelector, spinnerSelector, targetSelector, updateMethod, afterRenderCallback) ->
  $(moreTilesSelector).live('click', (event) ->
    event.preventDefault()

    if($(this).attr('disabled') != 'disabled')
      $(spinnerSelector).show()

      offset = $(tileSelector).length

      $.get(
        $(this).data('tile-path'),
        {offset: offset, partial_only: 'true'},
        ((data) ->
          $(spinnerSelector).hide()

          switch updateMethod
            when 'append'  then $(targetSelector).append(data.htmlContent)
            when 'replace' then $(targetSelector).replaceWith(data.htmlContent)

          if data.lastBatch
            $(moreTilesSelector).attr('disabled', 'disabled')

          if typeof(afterRenderCallback) == 'function'
            afterRenderCallback()
        ))
  )

window.bindShowMoreTilesLink = bindShowMoreTilesLink
