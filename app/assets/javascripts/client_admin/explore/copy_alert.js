var Airbo = window.Airbo || {};

Airbo.CopyAlert = (function(){
  function open() {
    swal(
      {
        title: "",
        text: "Tile has been copied to your board's drafts section.",
        customClass: "airbo tile_copied_lightbox",
        cancelButtonText: "Manage Your Board",
        animation: false,
        closeOnConfirm: true,
        showCancelButton: true,
        closeOnCancel: false
      },

      function(isConfirm){
        if (!isConfirm) {
          window.location.href = '/client_admin/tiles';
        }
      }
    );
  }
  return {
    open: open
  }
}());