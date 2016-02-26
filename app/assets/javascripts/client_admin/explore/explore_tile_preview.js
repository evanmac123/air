var Airbo = window.Airbo || {};

Airbo.ExploreTilePreview = (function(){
  var copyBtnSel = ".copy_to_board"
    , copyBtn
    , tileNavigationSelector = ".button_arrow"
  ;
  function initEvents() {
    copyBtn.click(function(event) {
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
          $(".viewer").html(data);
          // positionArrows();
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
  function initVars() {
    copyBtn = $(copyBtnSel);
    Airbo.ShareLink.init();
    Airbo.TileCarouselPage.init();
  }
  function init() {
    initVars();
    initEvents();
  }
  return {
    init: init
  }
}());

$(document).ready(function(){
  if( $(".explore_menu").length > 0 ) {
    Airbo.ExploreTilePreview.init();
  }
});