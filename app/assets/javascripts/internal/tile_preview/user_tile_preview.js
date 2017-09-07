var Airbo = window.Airbo || {};

Airbo.UserTilePreview =(function(){
  var pointValue,
      storageKey,
      tileId,
      progressType = "remote",
      progress,
      config,
      tileSelectedByNav = true,
      nextTileParams = { };

  function findCsrfToken() {
    return $('meta[name="csrf-token"]').attr('content');
  }


  function showOrHideStartOverButton(showFlag) {
    if (showFlag) {
      $('#guest_user_start_over_button').show();
    } else {
      $('#guest_user_start_over_button').hide();
    }
  }

  function grayoutTile(callback) {
    $('#spinner_large').fadeIn('slow', callback);
  }

  function ungrayoutTile() {
    return $('#spinner_large').fadeOut('slow');
  }

  function isRemote(){
    return progressType == "remote";
  }


  function isLocal(){
    return  !isRemote();
  }

  // TODO refactor this code since this logic for finding completed tiles is also
  // in progress_and_prize_bar.js
  function completedTileCount(){
    return completedTileIds().length;
  }

  function completedTileIds(){
    return keys(progress.completed).map(function(num){return parseInt(num);});
  }

  function keys(obj){
    return Object.keys(obj);
  }


  function grayoutAndScroll() {
    grayoutTile(function(){
      window.scrollTo(0,0);
    });
    return true;
  }

  function onNextTileReceivedByNavigation(data) {
    var container = $('.content .container.row');
    tileSelectedByNav = true;
    container.html(data.tile_content);
    initTile();
    showOrHideStartOverButton($('#slideshow .tile_holder').data('show-start-over') === true);
    ungrayoutTile();
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
    getTile(params, onNextTileReceivedByNavigation);
  }

  function getTileAfterAnswer(responseText){
    var params = $.extend(nextTileParams, {offset: 1, afterPosting: true});
    tileSelectedByNav =false;
    if(isLocal()){
      params =  $.extend(params, {demo: config.demo});
    }

    var cb = function(data, status, xhr) {

      var result = mergeReturnedDataWithLocal(data);

      var handler = function() {
        if (Airbo.UserTilePreview.fromSearch !== true) {
          if (result.all_tiles_done === true) {
            $('.content .container.row').replaceWith(result.tile_content);
            showOrHideStartOverButton(data.show_start_over_button === true);
          } else {
            $('#slideshow').html(result.tile_content);
            initTile();
            showOrHideStartOverButton($('#slideshow .tile_holder').data('show-start-over') === true);
            ungrayoutTile();
          }
        } else {
          Airbo.UserTileSearch.closeTileViewAfterAnswer();
        }
      };
      $.when(Airbo.ProgressAndPrizeBar.predisplayAnimations(result, responseText)).then(handler);

      Airbo.PubSub.publish("tileAnswered");
    };


    if(isLocal() && allTilesCompleted()){
      showAllFinished(responseText);
    }else{
      getTile(params, cb);
    }
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

  function getAnswerIndex(){
    return progress.completed[tileId];
  }

  function disableNonSelectedAnswers(answerIndex){
    $(".js-multiple-choice-answer").each(function(idx, el){
      if(idx !== answerIndex){
        $(this).attr("class","").addClass("nerfed_answer");
      }
    });
  }

  function setCompletedRightAnswer(answerIndex){
    var  clickAnswerTemplate = $("<div class='clicked_right_answer'></div>");


    el = $($(".js-multiple-choice-answer")[answerIndex])
    clickAnswerTemplate.text(el.text());
    el.replaceWith(clickAnswerTemplate);
  }

  function setCompletionUI(){
    var answerIndex = getAnswerIndex();
    var el = $(".tile_holder>.not_completed").removeClass("not_completed").addClass("special completed");
    if(tileSelectedByNav){
      el.removeClass("special");
    }
    setCompletedRightAnswer(answerIndex);
    disableNonSelectedAnswers(answerIndex);
  }

  function applyCompletionCheck(){
    if(isTileCompletedLocally()){
      setCompletionUI();
    }
  }

  function isTileCompletedLocally(){
    return completedTileIds().indexOf(tileId) !=-1;
  }

  function mergeReturnedDataWithLocal(data){
    var result = $.extend({}, data);
    if(isLocal()){
      result.all_tiles = progress.tileCount;
      result.completed_tiles = completedTileCount();
      result.ending_points = progress.starting_points;
      result.ending_tickets = 0;
      result.raffle_progress_bar = false;
      result.all_tiles_done = progress.tileCount === completedTileCount();

      applyCompletionCheck();
    }
    return result;
  }


  //TODO: Deprecate this and all related to old library implementation.
  function showAllFinished(responseText){

    var result = mergeReturnedDataWithLocal({}),
    backToHomepage = "<div id='tiles_done_message'><a href='/library/" + config.slug + "'>Return to homepage</a></div>";

    $.when(Airbo.ProgressAndPrizeBar.predisplayAnimations(result, responseText)).then(function(){
      $('.content .container.row').html(backToHomepage);
    });
  }

  function postTileCompletionPing(target) {
    var tileHolder = $(".tile_holder");
    var tileId = tileHolder.data("current-tile-id");
    var config = tileHolder.data("config");

    var tileType;

    if( $('body').hasClass("public-board") ) {
      tileType = "Public Tile";
    } else if( $(".js-multiple-choice-answer").hasClass("invitation_answer") ) {
      tileType = "Spouse Invite";
    } else if( $(".js-multiple-choice-answer").hasClass("change_email_answer") ) {
      tileType = "Email Change";
    }else {
      tileType = "User";
    }

    var pingParams = {
      tile_id: tileId,
      tile_module: config.type,
      allow_free_reponse: config.allowFreeResponse,
      is_anonymous: config.isAnonymous,
      tile_type: config.signature,
    };

    if( tileType == "Spouse Invite" ) {
      pingParams.sent_invite = target.hasClass("invitation_answer");
    }
    Airbo.Utils.ping('Tile - Completed', pingParams);
  }

  function handleForm(index){
    return form.serializeArray();
  }

  function postTileCompletion(target) {
    var response
      , answer
      , promise
      , idx = target.data("answerIndex")
      , form  = $("form#tile_completion")
      , url = form.attr("action")
    ;
     form.find("#answer_index").val(idx);

    if (isRemote()){
      postTileCompletionPing(target);
      response = $.ajax({
        type: "POST",
        url: url,
        data: form.serializeArray(),
      });
      return response;
    } else {
      promise = postToLocalStorage();
      promise.then(function(response){
        var data = response[2];
        progress.starting_points += data.value;
        progress.completed[data.tileId]=data.answer;
        Airbo.LocalStorage.set(storageKey, progress);
      });
      return promise;
    }
  }

  function removeTileIdFromAvailable(){
    var idx = findTileInAvailable();
    if (idx >= 0){
     progress.available.splice(idx, 1);
    }
  }

  function findTileInAvailable(){
    return $.inArray(tileId,progress.available);
  }

  function postToLocalStorage(){
    answer = Airbo.Utils.urlParamValueByname("answer_index", event.target.search);
    removeTileIdFromAvailable();
    //resolve with an object the simulates the return signature of jQuery ajax call i.e. [data, "statusText", xhr]
    //TODO flatten the returned object?
    return $.Deferred().resolve([null, "success", {answer: answer, tileId: tileId, value: pointValue,responseText: {starting_points: progress.starting_points, starting_tickets: 0 }}]);
  }

 function allTilesCompleted(){
   return (completedTileCount() === progress.tileCount);
 }

 function initNextTileParams(){
   nextTileParams = {
     partial_only: true,
     completed_only: $('#slideshow .tile_holder').data('completed-only'),
     previous_tile_ids: $('#slideshow .tile_holder').data('current-tile-ids')
   };
 }

 //TODO make sure not broken
 function targetAnswerClicked(target) {
   var tileCompletionPosted = postTileCompletion(target),
       grayedOutAndScrolled = grayoutAndScroll();

   $.when(tileCompletionPosted, grayedOutAndScrolled).then(function(xhr, res) {
     getTileAfterAnswer(xhr[2].responseText);
   });
 }

 //FIXME this is a shitty way to do this!!

 function rightAnswerClicked(answer){
   var formFun = function() {};
   if( answer.hasClass("invitation_answer") ){
     formFun = Airbo.DependentEmailForm.get;
   } else if( answer.hasClass("change_email_answer") ){
     formFun = Airbo.ChangeEmailForm.get;
   }

   $.when(formFun()).done(function() {
     targetAnswerClicked(answer);
   }).fail(function() {
     Airbo.TileAnswers.reinitEvents();
   });
 }

 function nextTileUrl(){
   var url;

   if(isRemote()){
     url ='/tiles/' + $('#slideshow .tile_holder').data('current-tile-id');
   }
   return url;
 }

 function nextTile(){
   return progress.available[0];
 }



 function initAnonymousTooltip(){
   $(".js-anonymous-tile-tooltip").tooltipster({
     theme: "tooltipster-shadow"
   });
 }



 function initTile(){
   var configObj = $(".tile_holder");
   tileId = configObj.data("current-tile-id");
   pointValue = configObj.data("point-value");
   config = $(".user_container").data("config");
   storageKey = config.key;
   initNextTileParams();
   setUpAnswers();
   initAnonymousTooltip();
   Airbo.Utils.ExternalLinkHandler.init();
 }

  function setUpAnswers() {
    Airbo.TileAnswers.init({
      onRightAnswer: rightAnswerClicked
    });
  }

  function bindTileCarouselNavigationButtons() {
    $("body").on('click', '#next, #prev', function(event) {
      var target = $(event.target)
      ;
      event.preventDefault();
      grayoutTile();
      getTileByNavigation(target);
    });
  }

  function init(fromSearch){
    this.fromSearch = fromSearch;
    bindTileCarouselNavigationButtons();
    initTile();
  }
  return {
   init: init
 };
}());

$(document).ready(function() {
  if( $(".tiles-index" ).length > 0) {
    Airbo.UserTilePreview.init();
  }
  // external tile preview
  if( $(".tile.tile-show").length > 0 ) {
    Airbo.TileAnswers.init();
  }
});
