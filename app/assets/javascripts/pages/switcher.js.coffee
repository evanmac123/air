switchMe = (position, container) ->
  if position == on
    $(container).find(".off").removeClass("engaged").addClass("disengaged")
    $(container).find(".on").removeClass("disengaged").addClass("engaged")
  else
    $(container).find(".on" ).removeClass("engaged").addClass("disengaged")
    $(container).find(".off").removeClass("disengaged").addClass("engaged")
$().ready ->
  $(".switcher #switcher_on").click ->
    switchMe on, ".switcher"

  $(".switcher #switcher_off").click ->
    switchMe off, ".switcher"
