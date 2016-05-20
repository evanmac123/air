var Airbo = window.Airbo || {};

Airbo.UserTilePreview =(function(){
  var pointValue
    , storageKey
    , tileId
    , nextTileUrl
    , progressType = "remote"
    , progress 
    , config 
    , nextTileParams = { }
  ;
  function findCsrfToken() {
    return $('meta[name="csrf-token"]').attr('content');
  };


  function showOrHideStartOverButton(showFlag) {
    if (showFlag) {
      $('#guest_user_start_over_button').show();
    } else {
      $('#guest_user_start_over_button').hide();
    }
  };

  function grayoutTile(callback) {
    return $('#spinner_large').fadeIn('slow', callback);
  };

  function ungrayoutTile() {
    return $('#spinner_large').fadeOut('slow');
  };

  function grayoutAndScroll() {
    grayoutTile(function(){
      window.scrollTo(0,0) 
    })
  }

  function nextTileRequested(data) {
    if (data.all_tiles_done === true) {
      $('.content .container.row').replaceWith(data.tile_content);
      showOrHideStartOverButton(data.show_start_over_button === true);
    } else {
      $('#slideshow').html(data.tile_content);
      initTile();
      showOrHideStartOverButton($('#slideshow .tile_holder').data('show-start-over') === true);
      ungrayoutTile();
    }

    if (data.show_conversion_form === true) {
      if ($("body").data("public-board") === true) {
        Airbo.ScheduleDemoModal.openModal();
        Airbo.ScheduleDemoModal.modalPing("Source", "Auto");
      } else {
        lightboxConversionForm();
      }
    }
  }


  function getTileSimple(offset){
    var params = $.extend(nextTileParams, {offset: offset, afterPosting: false});
    getTile(params, nextTileRequested)
  }


  function getTile(params, cb){
    $.ajax({
      type: "GET",
      url: nextTileUrl,
      data:params,
      success: cb
    });
  }


  function getTileAftherAnswer(responseText){
    var params = $.extend(nextTileParams, {offset: 1, afterPosting: true});

    var cb = function(data) {
      var handler = function() {
        if (data.all_tiles_done === true) {
          $('.content .container.row').replaceWith(data.tile_content);
          showOrHideStartOverButton(data.show_start_over_button === true);
        } else {
          $('#slideshow').html(data.tile_content);
          initTile();
          showOrHideStartOverButton($('#slideshow .tile_holder').data('show-start-over') === true);
          ungrayoutTile();
        }

        if (data.show_conversion_form === true) {
          if ($("body").data("public-board") === true) {
            Airbo.ScheduleDemoModal.openModal();
            Airbo.ScheduleDemoModal.modalPing("Source", "Auto");
          } else {
            lightboxConversionForm();
          }
        }

      };

      $.when(Airbo.ProgressAndPrizeBar.predisplayAnimations(data, responseText)).then(handler);
    };

    getTile(params, cb);
  }



  function postTileCompletion(event) {
    var response
      , answer
      , promise
    ;
    if (progressType==="remote"){
      var response = $.ajax({
          type: "POST",
          url: $(event.target).attr('href'),
          headers: { 'X-CSRF-Token': findCsrfToken() }
        });
        return response;
    }else{
      answer = Airbo.Utils.urlParamValueByname("answer_index", event.target.search);
      promise = $.Deferred().resolve({answer: answer, tileId: tileId, value: pointValue});
      promise.then(function(data){
        Airbo.LocalStorage.set(storageKey, data);
      });
      return promise;
    }
  };


  function rightAnswerClicked(event) {
    var tileCompletionPosted = postTileCompletion(event)
      , grayedOutAndScrolled = grayoutAndScroll(event)
    ;

    $.when( grayedOutAndScrolled, tileCompletionPosted).then(function() {
      getTileAftherAnswer(tileCompletionPosted.responseText);
    });
  }


 function initNextTileParams(){
   nextTileParams = {
     partial_only: true,
     completed_only: $('#slideshow .tile_holder').data('completed-only'),
     previous_tile_ids: $('#slideshow .tile_holder').data('current-tile-ids')
   };

   nextTileUrl = '/tiles/' + $('#slideshow .tile_holder').data('current-tile-id')
 }


  function initTile(){
    var configObj = $(".tile_holder");

    tileId = configObj.data("current-tile-id");
    pointValue = configObj.data("point-value");
    config = $(".user_container").data("config")
    storageKey = config.key

    if($(".client_admin-stock_tiles-show").length>0){
      progressType = "local";
    }

    initNextTileParams();
    setUpAnswers();
    Airbo.Utils.ExternalLinkHandler.init();
  }

  function setUpAnswers() {
    Airbo.TileAnswers.init({
      onRightAnswer: rightAnswerClicked
    });
  };

  function bindTileCarouselNavigationButtons() {
    $(function() {
      $("body").on('click', '#next', function(event) {
        event.preventDefault();
        grayoutTile();
        getTileSimple(1);
      });

      $("body").on('click', '#prev', function(event) {
        event.preventDefault();
        grayoutTile();
        getTileSimple(-1);
      });
    });
  };



  function init(){
    bindTileCarouselNavigationButtons();
    initTile();
  }
  return {
   init: init
  }
}());

$(document).ready(function() {
  if( $(".tiles-index, .client_admin-stock_tiles-show" ).length > 0) {

    Airbo.UserTilePreview.init();
  }
  // external tile preview
  if( $(".tile.tile-show, .client_admin-stock_tiles-show").length > 0 ) {
    Airbo.TileAnswers.init();
  }
});
