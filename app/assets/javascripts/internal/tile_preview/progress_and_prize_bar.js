var Airbo = window.Airbo || {};

Airbo.ProgressAndPrizeBar = (function(){


  //
  //  All tile progress functions and set up
  //
  var  tileCompletedBarSel = "#completed_tiles"
    , tileCompletedNumSel = "#completed_tiles_num"
    , tileCongratSel = "#congrat_header"
    , tileFullBarSel = "#tile_progress_bar"
    , tileCompleteDataSel = "#complete_info"
    , tileAllSel = "#all_tiles"
    , progressBarSel = '#completed_progress'
    , radialProgressBarSel  = '.progress-radial'
    , tileCompletedBar
    , tileCompletedNum
    , tileCongrat
    , tileFullBar
    , tileCompleteData
    , tileAll
    , progressBar
    , radialProgressBar
    , legacyBrowser
    , config
    , progress
  ;

function initDom(){

  tileCompletedBar = $(tileCompletedBarSel) ;
  tileCompletedNum = $(tileCompletedNumSel);
  tileCongrat = $(tileCongratSel);
  tileFullBar  = $(tileFullBarSel);
  tileCompleteData = $(tileCompleteDataSel)
  tileAll = $(tileAllSel);
  progressBar = $(progressBarSel);
  radialProgressBar = $(radialProgressBarSel);

}



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

  function currentProgress() {
    progressStr = $('.progress-radial').data("progress")
    return parseInt(progressStr);
  };

  function changeRadialProgressBarTo(progressNew){
   //FIXME small hack to disable progress bar animation when using custom colors.
        if($("meta[name='custom-palette']").length > 0){
          return;
        }
    radialProgressBar
          .removeClass("progress-" + currentProgress())
          .addClass("progress-" + progressNew);
  };

  function fillBarToFinalProgress(finalProgress, allTilesDone, callback) {

    radialProgressBar.addClass('counting');
    startProgress = currentProgress();
    stepsNumber = finalProgress - startProgress;
    return $({progressCount: 0}).animate({progressCount: stepsNumber}, {
      duration: 250,
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
        radialProgressBar.removeClass('counting');
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


  function calculateTileProgressWidth(allTiles, completedTiles){
    fullWidth = tileFullBar.outerWidth();
    if(allTiles != completedTiles){
      fullWidth -= tileAll.outerWidth();
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
    window.minWidth = parseInt( tileCompletedBar.css("width") );
    newWidth = calculateTileProgressWidth(allTiles, completedTiles);
    tileCompletedBar.css("width", newWidth);
    hideTileNumbers(allTiles, completedTiles);
    showTileNumbers(allTiles, completedTiles);
  }

  function setCongratText(){
    mq = window.matchMedia( "(min-width: 500px)" );
    if (mq.matches || legacyBrowser) {
      $("#congrat_text").text("You've finished all new tiles!");
    }
  }

  function hideTileNumbers(allTiles, completedTiles){
    tileCompletedBar.css("display", "block");       //show progress bar
    tileCongrat.css("display", "none");             //not show congrat message
    tileCompleteData.css("display", "none");
    tileCompletedNum.text(completedTiles);
    tileAll.text(allTiles);
    if(allTiles == completedTiles){
      tileAll.css("display", "none")
    }else{
      tileAll.css("visibility", "hidden");
    }
  }

  function showTileNumbers(allTiles, completedTiles){
    tileCompleteData.css("display", "block");              //show earned points
    tileAll.css("display", "block").css("visibility", "visible");//show all points

    if( allTiles == 0 || completedTiles == 0 ){
      tileCompletedBar.css("display", "none");
    }else if(allTiles == completedTiles){
      tileCompleteData.css("display", "none");
      tileCongrat.css("display", "block");
      tileAll.css("display", "none");
    }
  }

  function fillTileBar(allTiles, completedTiles){
    var deferred = $.Deferred();

    newWidth = calculateTileProgressWidth(allTiles, completedTiles);
    hideTileNumbers(allTiles, completedTiles);

    tileCompletedBar.animate({width: newWidth}, 750, 'linear', function(){
      showTileNumbers(allTiles, completedTiles);
      deferred.resolve();
    });

    return deferred.promise();
  }

  function setFlashes(tileData){

    $('#js-flashes').html(tileData.flash_content);
    $('.raffle_entries_num').html(tileData.ending_tickets);
  }

  //TODO simplify this usage of promises
  function predisplayAnimations(tileData, response) {
    var startingData = (typeof response ==="string") ?  $.parseJSON(response) : response;
    setFlashes(tileData);

    //second, fill tile bar
    return $.when( fillTileBar(tileData.all_tiles, tileData.completed_tiles) ).then(function(){
      //third, animate total points. fourth, animate raffle antries
      return $.when(animateCounter('total_points', startingData.starting_points, tileData.ending_points, 0.25)).then(function() {
        if( radialProgressBar.length > 0 ){
          return fillBar(startingData.starting_tickets, tileData.ending_tickets, tileData.raffle_progress_bar, tileData.all_tiles_done);
        }
      });
    });
  }




 function getUserProgress(config){
   if (config.persistLocally === true) {
     return Airbo.LocalStorage.get(config.key);
   }else{
     return config.completed
   }
 }

 function setPointsFromLocal(){
  $("#total_points").html(progress.starting_points);
 }

 function initLocalUserProgress(){
   progress = Airbo.LocalStorage.get(config.key) ||{available: config.tileIds, completed:{}, tileCount: config.tileCount, starting_points: 0,starting_tickets:0, ending_points:0}
   Airbo.LocalStorage.set(config.key,progress);
   setPointsFromLocal();
 }

//TODO refactor this code since this logic for finding completed tiles is also
 //in user_tile_preview.js

 function completedTileCount(){
   return completedTileIds().length;
 }

  function completedTileIds(){
    return keys(progress.completed).map(function(num){return parseInt(num);});
  }

  function keys(obj){
    return Object.keys(obj)
  }

 function setCompletedTiles(){
   completedTileIds().forEach(function(id){
     $("#single-tile-" + id).removeClass("not-completed").removeClass("special").addClass("completed")
   })
 }
  function onMoreTilesDisplayed(){
    if($(".placeholder_tile").length > 0){
      $('.show_more_tiles').hide();
    }
  }

  function init(){
    config = $(".user_container").data("config")
    var completedCount = config.completed
    if(config.persistLocally){
      initLocalUserProgress();
      completedCount = completedTileCount();
      setCompletedTiles();
    }

    legacyBrowser= config.legacyBrowser;
    initDom();
    setTileBar(config.available, completedCount);
    setCongratText();

    bindShowMoreTilesLink('.show_more_tiles', '.tile-wrapper', '#show_more_tiles_spinner', '#show_more_tiles_down_arrow', '#tile_wall', 'replace', onMoreTilesDisplayed );
  }
  return {
    setTileBar: setTileBar,
    setCongratText: setCongratText,
    predisplayAnimations: predisplayAnimations,
    init: init
  }
}());

$(document).ready(function() {
  if ($(".user_container").length > 0){
    Airbo.ProgressAndPrizeBar.init();
  }
});
