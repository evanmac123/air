$(document).ready(function() {
  $("#demo-search").on("keyup", function() {
    demoSearch($(this).val());
    demoFilter();
  });
});

var searchDemo = function(query, entries) {
  return entries.map(function(entry){
    if (entry.indexOf(query.toLowerCase()) === -1) {
      return false;
    } else {
      return true;
    }
  });
};

var demoSearch = function(query) {
  $(".demo").each(function() {
    $(this).show();
    var title = $(this).find(".title").text().toLowerCase();
    var match = searchDemo(query, [title]);
    if (match.indexOf(true) === -1) {
      $(this).toggle();
    }
  });
};
