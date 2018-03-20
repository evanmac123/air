Airbo.BoardsAndOrganizationMgr = (function() {
  function unlink(url) {
    $.ajax({
      url: url,
      type: "PATCH",
      data: { demo: { unlink: true } }
    })
      .done(function() {
        Airbo.Utils.flash("success", "Board successfully unlinked");
        $(".unlink").remove();
      })
      .fail(function() {
        console.log("unlink failed");
      });
  }

  function initLink() {
    $(".admin-demo .unlink").click(function(event) {
      event.preventDefault();
      var self = $(this);

      function doit() {
        unlink(self.attr("href"));
      }

      //TODO swich to sweetalert
      if (confirm("Are you sure")) {
        doit();
      }
      //Airbo.Utils.approve("are you sure?", doit)
    });
  }

  function initNewBoard() {
    $("form#new_organization #organization_name").blur(function(event) {
      $("form#new_organization #org_demo_name").val($(this).val() + " Board");
    });
  }

  function init() {
    if (
      Airbo.Utils.supportsFeatureByPresenceOfSelector(
        ".admin-unmatched_boards-index"
      )
    ) {
      if ($(".admin-demo").length > 0) {
        initLink();
      }

      Airbo.Utils.initChosen({
        create_option: function chosenAddOrg(term) {
          var chosen = this;
          window.location = "/admin/organizations/new";
        },
        create_option_text: "Create a new organization"
      });
    }
  }

  return {
    init: init
  };
})();
