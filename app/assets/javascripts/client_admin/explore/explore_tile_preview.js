var Airbo = window.Airbo || {};

Airbo.ExploreTilePreview = (function(){
  var copyBtnSel = ".copy_to_board"
    , copyBtn
    , tileNavigationSelector = ".button_arrow"
    , modalObj = Airbo.Utils.StandardModal()
    , modalId = "explore_tile_preview"
  ;
  function initEvents() {
    $(copyBtnSel).click(function(event) {
      event.preventDefault();
      copyUrl = $(this).attr("href");
      $.post(copyUrl, {},
        function(data) {
          if(data.success) {
            Airbo.CopyAlert.open();
          }
        },
        'json'
      );
    });

    $(tileNavigationSelector).click(function(e){
      e.preventDefault();

      $.ajax({
        type: "GET",
        dataType: "html",
        url: $(this).attr("href") ,
        data: {partial_only: true},
        success: function(data, status,xhr){
          open(data);
          // $(".viewer").html(data);
          // positionArrows();
          // initEvents();
        },

        error: function(jqXHR, textStatus, error){
          console.log(error);
        }
      });
    });

    $('.right_multiple_choice_answer').one("click", function(event) {
      event.preventDefault();
      $("#next_tile").trigger("click");
    });
  }
  function open(preview) {
    modalObj.setContent(preview);
    modalObj.open();
    
    Airbo.ShareLink.init();
    Airbo.TileCarouselPage.init();
    initEvents();
  }
  function initModalObj() {
    modalObj.init({
      modalId: modalId,
      modalClass: "tile_previews tile_previews-show",
      useAjaxModal: true,
      onOpenedEvent: function() {
        // initEvents();
      }
    });
  }
  function initVars() {
    initModalObj();
    // copyBtn = $(copyBtnSel);
  }
  function init() {
    initVars();
    initEvents();
  }
  return {
    init: init,
    open: open
  }
}());

$(document).ready(function(){
  if( $(".explore_menu").length > 0 ) {
    Airbo.ExploreTilePreview.init();
  }
});