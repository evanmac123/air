$(document).ready(function() {
  $("#admin-sidebar-toggle").click(function(e) {
      e.preventDefault();
      $("#admin-layout-wrapper").toggleClass("toggled");
  });
});
