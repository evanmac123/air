var Airbo = window.Airbo || {};

Airbo.PublicBoardSwitch = (function(){

  function init() {
    $("#public_switch").attr("checked", $("#public_switch").data("isPublic"));

    $(".new_public_board .switch").on("click", function(event) {
      var self = $(this).children("#public_switch");

      if ($("#public_switch").data("isPublic") === true) {
        var demo_id = $('.new_public_board').attr('id');
        $.ajax({
          url: "/client_admin/public_boards/" + demo_id,
          type: 'DELETE'
        });

        $("#public_switch").removeAttr("checked");
        $("#public_switch").data("isPublic", false);

        $("#public_board_field").attr("disabled", "true");
        $(".private").addClass("engaged").removeClass("disengaged");
        $(".public").addClass("disengaged").removeClass("engaged");
      } else {
        $.post("/client_admin/public_boards");

        $("#public_switch").attr("checked", "checked");
        $("#public_switch").data("isPublic", true);

        $("#public_board_field").removeAttr("disabled");
        $(".private").addClass("disengaged").removeClass("engaged");
        $(".public").addClass("engaged").removeClass("disengaged");
      }
    });
  }

  return {
    init: init
  };
}());

$(function(){
  if ($(".client_admin-shares-show").length > 0) {
    Airbo.PublicBoardSwitch.init();
  }
});
