function bindSeeMoreActs(queryPath, startingActOffset) {
  window.actOffset = startingActOffset;

  $('#see-more').bind('click', function(e) {
    mixpanel.track('saw more acts', {offset: actOffset});

    $('#see-more-spinner').show();
    $.get(queryPath, {offset: actOffset});
    e.preventDefault();
  });
}
