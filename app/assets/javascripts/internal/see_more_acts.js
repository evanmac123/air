var Airbo = window.Airbo || {};

Airbo.SeeMoreActs = (function(){

  function init() {
    $('#see-more-acts').on('click', function(e) {
      e.preventDefault();
      var page = $(this).data("page");
      var perPage = $(this).data("perPage");

      $(this).data().page++;
      $('#see-more-spinner').show();
      $('#see-more-acts .button_text').hide();

      $.get($(this).data('path'), { page: page, per_page: perPage }, function(data) {
        $("#user-acts").append(data.content);
        if (data.lastPage === true) {
          $('#see-more-acts').hide();
        } else {
          $('#see-more-acts .button_text').show();
          $('#see-more-spinner').hide();
        }
      });
    });
  }

  return {
    init: init
  };
}());

$(function(){
  if ($("#see-more-acts").length > 0) {
    Airbo.SeeMoreActs.init();
  }
});
