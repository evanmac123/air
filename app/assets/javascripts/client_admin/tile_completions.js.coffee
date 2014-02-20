$(document).ready ->
  $(document).ajaxStart -> 
    $('.tile_completions_controls #spinner').show()
  $(document).ajaxStop ->  
    $('.tile_completions_controls #spinner').hide()
