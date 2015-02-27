window.moveTileConfirmationModal = ->
	$(".move-tile-confirm .cancel").click (e) ->
		e.preventDefault()
		window.moveConfirmationDeferred.reject()
		$(".manage_section").sortable( "cancel" ).sortable( "refresh" )
		$(".move-tile-confirm").foundation('reveal', 'close')

	$(".move-tile-confirm .confirm").click (e) ->
		e.preventDefault()
		$(".move-tile-confirm").foundation('reveal', 'close')

	$(document).on 'close.fndtn.reveal', '.move-tile-confirm', ->
		window.moveConfirmationDeferred.resolve()