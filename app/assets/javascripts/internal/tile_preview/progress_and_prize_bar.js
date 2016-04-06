var Airbo = window.Airbo || {};

Airbo.ProgressAndPrizeBar = (function(){
  function animateCounter(domID, previous, current, duration, callback) {
    var counter = new countUp(domID, previous, current, 0, duration);
    counter.useEasing = false;

    var element = $('#' + domID);
    element.addClass('counting');
    counter.start(function() {
      element.removeClass('counting');
      if(typeof(callback) === 'function') {
        callback();
      }
    });
  }
  function progressBar() {return $('#completed_progress')};
  function radialProgressBar() {return $('.progress-radial')};
  function currentProgress() {
    progressStr = $('.progress-radial').data("progress")
    return parseInt(progressStr);
  };
  function changeRadialProgressBarTo(progressNew){
   //FIXME small hack to disable progress bar animation when using custom colors.
        if($("meta[name='custom-palette']").length > 0){
          return;
        }
    radialProgressBar()
          .removeClass("progress-" + currentProgress())
          .addClass("progress-" + progressNew);
  };
  function fillBarToFinalProgress(finalProgress, allTilesDone, callback) {

    radialProgressBar().addClass('counting');
    startProgress = currentProgress();
    stepsNumber = finalProgress - startProgress;
    return $({progressCount: 0}).animate({progressCount: stepsNumber}, {
      duration: 750,
      easing: 'linear',
      step: function(progressCount){
        //FIXME small hack to disable progress bar animation when using custom colors.
        if($("meta[name='custom-palette']").length > 0){
          return;
        }
        progressNew = startProgress + parseInt(progressCount);
        changeRadialProgressBarTo(progressNew);
      },
      complete: function() {
        radialProgressBar().removeClass('counting');
        if(typeof(callback) === 'function') {
          callback();
        }
      }
    });
  };
  function fillBarEntirely(previousTickets, currentTickets, finalProgress, allTilesDone) {
    var deferred = $.Deferred();

    var emptyBarCallback = function() {
      changeRadialProgressBarTo(0);
      fillBarToFinalProgress(finalProgress, allTilesDone, function() {
        animateCounter('raffle_entries', previousTickets, currentTickets, 0.1, deferred.resolve);
      });
    }

    fillBarToFinalProgress(200, allTilesDone, emptyBarCallback);
    return deferred.promise();
  };
  function fillBar(previousTickets, currentTickets, finalProgress, allTilesDone) {
    var ticketsIncreased = (previousTickets < currentTickets);
    if(ticketsIncreased) {
      return(fillBarEntirely(previousTickets, currentTickets, finalProgress, allTilesDone));
    } else {
      return(fillBarToFinalProgress(finalProgress, allTilesDone));
    }
  }
  function scrollToTop() { $.Deferred(window.scrollTo(0,0)).promise(); }
  function tileCompletedPreloadAnimations() {
    var callbacksDoneDeferred = $.Deferred();

    $.when(grayoutTile()).
      then(scrollToTop).
      then(function(){callbacksDoneDeferred.resolve()});

    return callbacksDoneDeferred.promise();
  }
  //
  //  All tile progress functions and set up
  //
  function tileCompletedBar(){ return $("#completed_tiles"); }
  function tileCompletedNum(){ return $("#completed_tiles_num"); }
  function tileCongrat(){ return $("#congrat_header"); }
  var tileFullBar = function(){ return $("#tile_progress_bar"); }
  var tileCompleteData = function() { return $("#complete_info"); }
  var tileAll = function(){ return $("#all_tiles"); }

  function calculateTileProgressWidth(allTiles, completedTiles){
    fullWidth = tileFullBar().outerWidth();
    if(allTiles != completedTiles){
      fullWidth -= tileAll().outerWidth();
    }
    newWidth = parseInt( fullWidth * completedTiles / allTiles);
    if(completedTiles == 0){
      newWidth = 0;
    }else if(minWidth > newWidth){
      newWidth = minWidth;
    }else if( allTiles == completedTiles ){
      newWidth = "100%";
    }
    return newWidth;
  }
  function setTileBar(allTiles, completedTiles){
    window.minWidth = parseInt( tileCompletedBar().css("width") );
    newWidth = calculateTileProgressWidth(allTiles, completedTiles);
    tileCompletedBar().css("width", newWidth);
    hideTileNumbers(allTiles, completedTiles);
    showTileNumbers(allTiles, completedTiles);
  }
  function setCongratText(){
    mq = window.matchMedia( "(min-width: 500px)" );
    if (mq.matches || window.oldBrowser) {
      $("#congrat_text").text("You've finished all new tiles!");
    }
  }
  function hideTileNumbers(allTiles, completedTiles){
    tileCompletedBar().css("display", "block");       //show progress bar
    tileCongrat().css("display", "none");             //not show congrat message
    tileCompleteData().css("display", "none");
    tileCompletedNum().text(completedTiles);
    tileAll().text(allTiles);
    if(allTiles == completedTiles){
      tileAll().css("display", "none")
    }else{
      tileAll().css("visibility", "hidden");
    }
  }

  function showTileNumbers(allTiles, completedTiles){
    tileCompleteData().css("display", "block");              //show earned points
    tileAll().css("display", "block").css("visibility", "visible");//show all points

    if( allTiles == 0 || completedTiles == 0 ){
      tileCompletedBar().css("display", "none");
    }else if(allTiles == completedTiles){
      tileCompleteData().css("display", "none");
      tileCongrat().css("display", "block");
      tileAll().css("display", "none");
    }
  }

  function fillTileBar(allTiles, completedTiles){
    var deferred = $.Deferred();

    newWidth = calculateTileProgressWidth(allTiles, completedTiles);
    hideTileNumbers(allTiles, completedTiles);
    tileCompletedBar().animate({width: newWidth}, 750, 'linear', function(){
      showTileNumbers(allTiles, completedTiles);
      deferred.resolve();
    });

    return deferred.promise();
  }

  //
  //  Makes all progress animation
  //
  function predisplayAnimations(tileData, tilePosting) {
    //first, we post new tile
    $.when(tilePosting).then(function() {
      var startingData = $.parseJSON(tilePosting.responseText);
      $('#js-flashes').html(tileData.flash_content);
      $('.raffle_entries_num').html(tileData.ending_tickets);
      //second, fill tile bar
      return $.when( fillTileBar(tileData.all_tiles, tileData.completed_tiles) ).then(function(){
        //third, animate total points. fourth, animate raffle antries
        return $.when(animateCounter('total_points', startingData.starting_points, tileData.ending_points, 0.5)).then(function() {
          if( radialProgressBar().length > 0 ){
            return fillBar(startingData.starting_tickets, tileData.ending_tickets, tileData.raffle_progress_bar, tileData.all_tiles_done);
          }
        });
      });
    })
  }
  return {
    predisplayAnimations: predisplayAnimations,
    tileCompletedPreloadAnimations: tileCompletedPreloadAnimations,
    setTileBar: setTileBar,
    setCongratText: setCongratText
  }
}());
