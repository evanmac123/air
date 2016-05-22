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
    $('#spinner_large').fadeIn('slow', callback);
  };

  function ungrayoutTile() {
    return $('#spinner_large').fadeOut('slow');
  };

  function grayoutAndScroll() {
    grayoutTile(function(){
      window.scrollTo(0,0) 
    })
    return true;
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


  function isRemote(){
    return progressType=="remote"
  }


  function isLocal(){
    return  !isRemote();
  }

  function completed_tiles(obj){
    return Object.keys(obj).length;
  }

  function getTileAftherAnswer(responseText){
    var params = $.extend(nextTileParams, {offset: 1, afterPosting: true});
    if(isLocal()){

      params =  $.extend(params, {demo: config.demo});
    }

    var cb = function(data) {
      console.log("in callback", Date.now());
      var result = $.extend({}, data);

      if(isLocal()){    
        result.all_tiles = progress.tileCount
        result.completed_tiles = completed_tiles(progress.completed)
        result.ending_points = progress.starting_points
        result.ending_tickets = 0
        result.raffle_progress_bar = false 
        result.all_tiles_done = progress.tileCount === progress.completed.length
      }

      var handler = function() {
        if (result.all_tiles_done === true) {
          $('.content .container.row').replaceWith(result.tile_content);
          showOrHideStartOverButton(data.show_start_over_button === true);
        } else {
          $('#slideshow').html(result.tile_content);
          initTile();
          showOrHideStartOverButton($('#slideshow .tile_holder').data('show-start-over') === true);
          ungrayoutTile();

          console.log("tiles displayed", Date.now());
        }

        if (result.show_conversion_form === true) {
          if ($("body").data("public-board") === true) {
            Airbo.ScheduleDemoModal.openModal();
            Airbo.ScheduleDemoModal.modalPing("Source", "Auto");
          } else {
            lightboxConversionForm();
          }
        }

      };
      $.when(Airbo.ProgressAndPrizeBar.predisplayAnimations(result, responseText)).then(handler);
    };

    getTile(params, cb);

    console.log("get tile called", Date.now());
  }



  function postTileCompletion(event) {
    var response
      , answer
      , promise
    ;
    if (isRemote()){
      var response = $.ajax({
          type: "POST",
          url: $(event.target).attr('href'),
          headers: { 'X-CSRF-Token': findCsrfToken() }
        });
        return response;
    }else{
      promise = postToLocalStorage();
      promise.then(function(data){

      progress.starting_points += data.value;
        progress.completed[data.tileId]=data.answer;
        Airbo.LocalStorage.set(storageKey, progress);
      });
      return promise;
    }
  };


  function postToLocalStorage(){
    progress = Airbo.LocalStorage.get(storageKey);
    answer = Airbo.Utils.urlParamValueByname("answer_index", event.target.search);
    return $.Deferred().resolve({answer: answer, tileId: tileId, value: pointValue,responseText: {starting_points: progress.starting_points, starting_tickets: 0 }});
  }

  function rightAnswerClicked(event) {
    var tileCompletionPosted = postTileCompletion(event)
      , grayedOutAndScrolled = grayoutAndScroll(event)
    ;
    $.when( tileCompletionPosted,grayedOutAndScrolled).done(function(data, res) {

      getTileAftherAnswer(data.responseText);
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
   console.log("UserTilePreview")
    Airbo.UserTilePreview.init();
  }
  // external tile preview
  if( $(".tile.tile-show, .client_admin-stock_tiles-show").length > 0 ) {
    Airbo.TileAnswers.init();
  }
});
