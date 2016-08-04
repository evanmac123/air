$(document).ready(function() {
  $(".active-filter").toggle();

  var demoFilter = function(filter) {
    $(".demo").each(function() {
      $(this).show();
      if (filter === "all") return;
      var quality = $(this).attr('data-companySize');
      if (quality != filter) {
        $(this).toggle();
      }
    });
  };

  var checkFilter = function(filter) {
    if ($(".active-filter").val() != "all") {
      demoFilter(filter);
    }
  };

  $(document).on('click','.filter-button',function() {
    $(".active-filter").toggle().removeClass("active-filter");

    $(this).addClass("active-filter").toggle();

    demoFilter($(this).val());
  });
});
