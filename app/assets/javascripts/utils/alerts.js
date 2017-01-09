var Airbo = window.Airbo || {Utils:{}};
Airbo.Utils.Messages = {

  incompleteTile: "This Tile is incomplete. Please add all required fields and fix any errors before posting."

};

Airbo.Utils.alert = function (text) {
  swal({
    title: "",
    text: text,
    customClass: "airbo",
  });
};

Airbo.Utils.approve = function (text, cb) {
  swal(
    {
      title: "",
      text: text,
      cancelButtonText: "Cancel",
      animation: false,
      customClass: "airbo",
      closeOnConfirm: true,
      showCancelButton: true,
      closeOnCancel: true
    },

    function(isConfirm){
      if (isConfirm) {

        cb &&cb();
      }
    }
  );
};
