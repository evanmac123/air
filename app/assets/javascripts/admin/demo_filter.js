$(document).ready(function() {
  $(document).on('click','.filter-button', function() {
    $(this).addClass("active-filter").removeClass("filter-button").css({ "background-color": "#fff", "color": "#48bfff" });

    demoFilter();
  });

  $(document).on('click','.active-filter', function() {
    $(this).removeClass("active-filter").addClass("filter-button").css({ "background-color": "", "color": "" });

    demoReset(this);
  });
});

var demoFilter = function() {
  var currentSearch = $("#demo-search").val();
  demoSearch(currentSearch);
  
  $(".demo:visible").each(function() {
    var demo = this;

    $(".active-filter").each(function() {
      toggleDemos(demo, this);
    });
  });
};

var demoReset = function(filter) {
  $(".demo:hidden").each(function() {
    var demo = this;
    toggleDemos(demo, filter);
  });

  demoFilter();
};

var toggleDemos = function(demo, filter) {
  if ($(filter).data().type === "size") {
    var size = $(demo).attr('data-companySize');
    if (size != $(filter).val()) {
      return $(demo).toggle();
    }
  }

  if ($(filter).data().type === "paidStatus") {
    var isPaid = $(demo).attr('data-isPaid');
    if (isPaid != $(filter).data().paid.toString()) {
      return $(demo).toggle();
    }
  }
};
