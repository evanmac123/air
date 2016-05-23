var Airbo = window.Airbo || {};

Airbo.UserTilePreview =(function(){
  var pointValue
    , storageKey
    , tileId
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

  function isRemote(){
    return progressType=="remote"
  }


  function isLocal(){
    return  !isRemote();
  }

  function completedTiles(){
    return numKeys(progress.completed)
  }

  function numKeys(obj){
    return Object.keys(obj).length;
  }


  function grayoutAndScroll() {
    grayoutTile(function(){
      window.scrollTo(0,0) 
    })
    return true;
  }

  function onNextTileReceived(data) {
   var container = $('.content .container.row');
    if (data.all_tiles_done === true) {
    container.replaceWith(data.tile_content);
      showOrHideStartOverButton(data.show_start_over_button === true);
    } else {
      container.html(data.tile_content);
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


  function navigationParams(target){
    var dir = target.is("#next") ? 1 : -1;
    if(isRemote()){
      return {offset: dir };
    }else{
      return {url: target.attr("href"), offset: 0 };
    }
  }

  function getTileByNavigation(target){
    var params = $.extend(nextTileParams,  navigationParams(target), {afterPosting: false});
    getTile(params, onNextTileReceived);
  }


  function getTile(params, cb){
    var url = params.url || nextTileUrl();
     $.ajax({
      type: "GET",
      url: url,
      data: params,
      success: cb
    });
  }

  function getTileAfterAnswer(responseText){
    var params = $.extend(nextTileParams, {offset: 1, afterPosting: true});
    if(isLocal()){

      params =  $.extend(params, {demo: config.demo});
    }

    var cb = function(data, status, xhr) {
      console.log("in callback", Date.now());
      var result = $.extend({}, data);
      if(isLocal()){    
        result.all_tiles = progress.tileCount
        result.completed_tiles = completedTiles()
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


    if(isLocal() && allTilesCompleted()){
      alert("hi");
    }else{
      getTile(params, cb);
    }
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
          headers: { 'X-CSRF-Token': findCsrfToken() },
          dataType: "json"
        });
        return response;
    }else{
      promise = postToLocalStorage();
      promise.then(function(response){
        var data = response[2];
        progress.starting_points += data.value;
        progress.completed[data.tileId]=data.answer;
        Airbo.LocalStorage.set(storageKey, progress);
      });
      return promise;
    }
  };

  function removeTileIdFromAvailable(){
    var idx = findTileInAvailable()
    if (idx >= 0){
     progress.available.splice(idx, 1);
    }
  }

  function findTileInAvailable(){
    return $.inArray(tileId,progress.available) 
  }

  function postToLocalStorage(){
    progress = Airbo.LocalStorage.get(storageKey);
    answer = Airbo.Utils.urlParamValueByname("answer_index", event.target.search);
    removeTileIdFromAvailable();
    //resolve with an object the simulates the return signature of jQuery ajax call i.e. [data, "statusText", xhr]
    //TODO flatten the returned object?
    return $.Deferred().resolve([null, "success", {answer: answer, tileId: tileId, value: pointValue,responseText: {starting_points: progress.starting_points, starting_tickets: 0 }}]);
  }

  function rightAnswerClicked(event) {
    var tileCompletionPosted = postTileCompletion(event)
      , grayedOutAndScrolled = grayoutAndScroll(event)
    ;
    $.when( tileCompletionPosted,grayedOutAndScrolled).then(function(xhr, res) {
      getTileAfterAnswer(xhr[2].responseText);
    });
  }

 function allTilesCompleted(){
   return (completedTiles() === progress.tileCount)
 }

 function initNextTileParams(){
   nextTileParams = {
     partial_only: true,
     completed_only: $('#slideshow .tile_holder').data('completed-only'),
     previous_tile_ids: $('#slideshow .tile_holder').data('current-tile-ids')
   };
 }

 function nextTileUrl(){
   var url;

   if(isRemote()){
     url ='/tiles/' + $('#slideshow .tile_holder').data('current-tile-id')
   }else{
     url ='/client_admin/library_tiles/' + nextTile(); 
   }
   return url;
 }

 function nextTile(){
   return progress.available[0];
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
    $("body").on('click', '#next, #prev', function(event) {
      var target = $(event.target)
      ;
      event.preventDefault();
      grayoutTile();
      getTileByNavigation(target);
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
  if( $(".tile.tile-show").length > 0 ) {
    Airbo.TileAnswers.init();
  }
});
