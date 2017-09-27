var Airbo = window.Airbo || {};

Airbo.PublicBoardControls = (function(){

  function togglePublic() {
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

  function disablePublicLink() {
    $('#public_board_field').on('keydown keyup keypress', function(event) {
      if (!(event.ctrlKey || event.altKey || event.metaKey)) {
        event.preventDefault();
      }
    });

    $('#public_board_field').on('click', function(event) {
      event.preventDefault();
      $(event.target).focus().select();
    });
  }

  function manageUsers() {
    $('#digest_include_sms').on('change', function(e) {
      var ischecked = $(this).is(':checked');
      if (ischecked) {
        $(".sms-recipients").show();
      } else {
        $(".sms-recipients").hide();
      }

      window.resizeEmailPreview();
    });

    $('#digest_digest_send_to').on('change', function(event) {
      if ($('#digest_digest_send_to option:selected').text() === "All Users") {
        $('.js-all-user-recipients').show();
        $('.js-all-activated-user-recipients').hide();
      } else if ($('#digest_digest_send_to option:selected').text() === "Activated Users") {
        $('.js-all-user-recipients').hide();
        $('.js-all-activated-user-recipients').show();
      }
    });

    if ($('#digest_include_sms').is(':checked')) {
      $(".sms-recipients").show();
    }

    $('#digest_digest_send_to').trigger('change');
  }

  function init() {
    $("#public_switch").attr("checked", $("#public_switch").data("isPublic"));
    togglePublic();
    disablePublicLink();
    manageUsers();
  }

  return {
    init: init
  };
}());

$(function(){
  if ($(".client_admin-shares-show").length > 0) {
    Airbo.PublicBoardControls.init();
  }
});
