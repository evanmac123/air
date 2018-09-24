var Airbo = window.Airbo || { Utils: {} };
Airbo.Utils.Messages = {
  incompleteTile:
    "This Tile is incomplete. Please add all required fields and fix any errors before posting."
};

Airbo.Utils.alert = function(text) {
  swal({
    title: "",
    text: text,
    className: "airbo"
  });
};

Airbo.Utils.alertSuccess = function(title, text, buttonText) {
  swal({
    title: title,
    text: text,
    className: "airbo",
    type: "success",
    buttons: [buttonText || "Continue"]
  });
};

Airbo.Utils.approve = function(text, cb) {
  swal(
    {
      title: "",
      text: text,
      buttons: ["Cancel", "OK"],
      className: "airbo"
    },

    function(isConfirm) {
      if (isConfirm) {
        cb && cb();
      }
    }
  );
};
