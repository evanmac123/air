function bindSeeMoreActs(queryPath, startingActOffset) {
  window.actOffset = startingActOffset;

  $('#see-more').on('click', function(e) {
    e.preventDefault();
    $('#see-more-spinner').show();
    $('#see-more #button_text').hide();
    $.get(queryPath, { offset: actOffset }, function(data) {
      $('#see-more #button_text').show();
      $('#see-more-spinner').hide();
    });
  });
}
