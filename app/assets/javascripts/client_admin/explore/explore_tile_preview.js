var Airbo = window.Airbo || {};

Airbo.ExploreTilePreview = (function(){
  var copyBtnSel = ".copy_to_board"
    // , copyBtn
    // , tileNavigationSelector = ".button_arrow"
    , modalObj = Airbo.Utils.StandardModal()
    , modalId = "explore_tile_preview"
    , arrowsObj// = Airbo.TilePreivewArrows()
    , introShowed = false
  ;
  function tileContainerSizes() {
    tileContainer = $(".tile_full_image")[0]  || $(".pholder.image")[0];
    if( !tileContainer ) {
      return null;
    }
    return tileContainer.getBoundingClientRect();
  }
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

    // $(tileNavigationSelector).click(function(e){
    //   e.preventDefault();

    //   $.ajax({
    //     type: "GET",
    //     dataType: "html",
    //     url: $(this).attr("href") ,
    //     data: {partial_only: true},
    //     success: function(data, status,xhr){
    //       open(data);
    //       // $(".viewer").html(data);
    //       // positionArrows();
    //       // initEvents();
    //     },

    //     error: function(jqXHR, textStatus, error){
    //       console.log(error);
    //     }
    //   });
    // });

    $('.right_multiple_choice_answer').one("click", function(event) {
      event.preventDefault();
      $("#next_tile").trigger("click");
    });
  }
  function runIntro() {
    if (introShowed) return;
    introShowed = true;
    var menuElWithIntro = $(".preview_menu_item");
    if( menuElWithIntro.data('intro').length == 0 ) return;

    var intro = introJs();
    intro.setOptions({
      showStepNumbers: false,
      doneLabel: 'Got it',
      tooltipClass: "airbo_preview_intro"
    });
    intro.start();
  }
  function open(preview) {
    modalObj.setContent(preview);
    modalObj.open();

    Airbo.ShareLink.init();
    Airbo.TileCarouselPage.init();
    arrowsObj.initEvents();
    initEvents();
  }
  function initModalObj() {
    modalObj.init({
      modalId: modalId,
      modalClass: "tile_previews tile_previews-show",
      useAjaxModal: true,
      onOpenedEvent: function() {
        // initEvents();
        arrowsObj.position();
        runIntro();
      }
    });
  }
  function initFakeModalObj() {
    modalObj = Airbo.Utils.FakeModal();
    modalObj.init({
      containerSel: ".content",
      onOpenedEvent: function() {
        arrowsObj.position();
        runIntro();
      }
    });
  }
  // function initVars() {
    
  //   // copyBtn = $(copyBtnSel);
  // }
  function init(fakeModal) {
    if(fakeModal) {
      initFakeModalObj();
    } else {
      initModalObj();
    }
    arrowsObj = Airbo.TilePreivewArrows();
    arrowsObj.init(this, {buttonSize: 40, offset: 20});

    initEvents();
    return this;
  }
  return {
    init: init,
    open: open,
    tileContainerSizes: tileContainerSizes
  }
}());

$(document).ready(function(){
  if( $(".explore_menu").length > 0 ) {
    preview = Airbo.ExploreTilePreview.init(true);
    preview.open();
  }
});