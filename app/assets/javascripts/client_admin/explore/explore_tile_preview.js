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
  function ping(action) {
    var tile_id;
    tile_id = $("[data-current-tile-id]").data("current-tile-id");
    Airbo.Utils.ping('Explore page - Interaction', {action: action, tile_id: tile_id});
  }
  function tileContainerSizes() {
    tileContainer = $(".tile_full_image")[0];
    if( !tileContainer ) {
      return null;
    }
    return tileContainer.getBoundingClientRect();
  }
  function initEvents() {
    $(copyBtnSel + ":not([disabled])").click(function(event) {
      event.preventDefault();
      var button = $(this);
      button.attr("disabled", "disabled");
      copyUrl = button.attr("href");
      $.post(copyUrl, {},
        function(data) {
          if(data.success) {
            button.removeAttr("disabled");
            Airbo.CopyAlert.open();
          }
        },
        'json'
      );
    });

    $('.right_multiple_choice_answer').one("click", function(event) {
      event.preventDefault();
      $("#next_tile").trigger("click");
      ping("Clicked Answer");
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
      modalClass: "tile_previews tile_previews-show bg-user-side",
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
    arrowsObj.init(this, {
      buttonSize: 40,
      offset: 20,
      afterNext: function() {
        ping("Clicked arrow to next tile");
      },
      afterPrev: function() {
        ping("Clicked arrow to previous tile");
      },
    });

    initEvents();
    return this;
  }
  return {
    init: init,
    open: open,
    tileContainerSizes: tileContainerSizes
  }
}());

Airbo.GuestExploreTilePreview = (function(){
  function open() {

  }
  function init() {
    Airbo.ShareLink.init();
    Airbo.TileCarouselPage.init();
    return this;
  }
  return {
    init: init,
    open: open
  }
}());

$(document).ready(function(){
  if( $(".explore_menu").length > 0 ) {
    var preview = Airbo.ExploreTilePreview.init(true);
    preview.open();
  }
  if( $(".single_tile_guest_layout").length > 0 ) {
    Airbo.GuestExploreTilePreview.init();
  }
});
