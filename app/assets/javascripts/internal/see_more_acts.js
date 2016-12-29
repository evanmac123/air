function bindSeeMoreActs(queryPath, startingActOffset) {
  window.actOffset = startingActOffset;
  debugger

  $('#see-more').bind('click', function(e) {
    $('#see-more-spinner').show();
    $.get(queryPath, { offset: actOffset });
    e.preventDefault();
  });
}
