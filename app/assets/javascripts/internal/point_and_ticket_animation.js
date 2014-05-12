var animateCounter = function(domID, previous, current, duration, callback) {
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
};

var progressBar = function() {return $('#completed_progress')};
var radialProgressBar = function() {return $('.progress-radial')};
var currentProgress = function() {
  progressStr = $('.progress-radial').attr('class').match( /progress\-([0-9]+).*/)[1];
  return parseInt(progressStr);
};
var changeRadialProgressBarTo = function(progressNew){
  radialProgressBar()
        .removeClass("progress-" + currentProgress())
        .addClass("progress-" + progressNew);
};

var fillBarToFinalProgress = function(finalProgress, allTilesDone, callback) {
  radialProgressBar().addClass('counting');
  startProgress = currentProgress();
  stepsNumber = finalProgress - startProgress;
  return $({progressCount: 0}).animate({progressCount: stepsNumber}, {
    duration: 750,
    easing: 'linear',
    step: function(progressCount){
      //console.log(progressCount);
      progressNew = startProgress + parseInt(progressCount);
      //console.log(progressNew);
      changeRadialProgressBarTo(progressNew);
    },
    complete: function() {
      radialProgressBar().removeClass('counting');
      if(typeof(callback) === 'function') {
        callback();
      }
    } 
  });
  /*, 750, 'linear', function() {
    radialProgressBar().removeClass('counting');
    if(typeof(callback) === 'function') {
      callback();
    } 
  });
  /*progressBar().addClass('counting');
  return progressBar().animate({width: finalPercentage}, 750, 'linear', function() {
    progressBar().removeClass('counting');
    if(typeof(callback) === 'function') {
      callback();
    } 
  });*/
};

var loadFollowingTile = function() {
  loadNextTileWithOffset(1);
}

var fillBarEntirely = function(previousTickets, currentTickets, finalProgress, allTilesDone) {
  var deferred = $.Deferred();

  var emptyBarCallback = function() {
    changeRadialProgressBarTo(0);
    //console.log("emptyBarCallback");
    fillBarToFinalProgress(finalProgress, allTilesDone, function() {
      //animateCounter('user_tickets', previousTickets, currentTickets, 0.1, deferred.resolve);
      animateCounter('raffle_entries', previousTickets, currentTickets, 0.1, deferred.resolve);
    });
  }

  //progressBar().addClass('counting');
  //progressBar().animate({width: '100%'}, 750, 'linear', emptyBarCallback);
  fillBarToFinalProgress(200, allTilesDone, emptyBarCallback);
  return deferred.promise();
};

var fillBar = function(previousTickets, currentTickets, finalProgress, allTilesDone) {
  var ticketsIncreased = (previousTickets < currentTickets);
  if(ticketsIncreased) {
    return(fillBarEntirely(previousTickets, currentTickets, finalProgress, allTilesDone));
  } else {
    return(fillBarToFinalProgress(finalProgress, allTilesDone)); 
  }
}

var scrollToTop = function() { $.Deferred(window.scrollTo(0,0)).promise(); }

var pointCounter = function() {
  var originalPoints = parseInt($('#tile_point_value').text());
  return(new countUp('tile_point_value', originalPoints, 0, 0, 1.0));
}

var highlightEarnablePoints = function() {
  $('.earnable_points').css('background', '#4FAA60').css('box-shadow', 'none');
}

var tileCompletedPreloadAnimations = function() {
  highlightEarnablePoints();

  var callbacksDoneDeferred = $.Deferred();

  pointCounter().start(function() {
    $.when(grayoutTile()).
      then(scrollToTop).
      then(function(){callbacksDoneDeferred.resolve()})
  });

  return callbacksDoneDeferred.promise();
}

var markCompletedRightAnswer = function(event) {
  $(event.target).addClass('clicked_right_answer');
}

var tileCompletedBar = function(){ return $("#completed_tiles"); }
var tileCompletedNum = function(){ return $("#completed_tiles_num"); }
var getTileCompletedNum = function(){ 
  return parseInt( tileCompletedNum().text() ); 
}
var tileFullBar = function(){ return $("#tile_progress_bar"); }
var tileCompleteData = function() { return $("#complete_info"); }
var tileAll = function(){ return $("#all_tiles"); }

var calculateTileProgressWidth = function(allTiles, completedTiles){
  newWidth = parseInt(tileFullBar().outerWidth() * completedTiles / allTiles);
  currentWidth = tileCompletedBar().outerWidth();
  if(currentWidth > newWidth){
    newWidth = currentWidth; 
  }
  return newWidth;
}

var setTileBarWidth = function(allTiles, completedTiles){
  newWidth = calculateTileProgressWidth(allTiles, completedTiles);
  currentWidth = tileCompletedBar().outerWidth();
  if(currentWidth < newWidth){
    tileCompletedBar().css("width", "" + newWidth + "px");
  }
}

var hideTileNumbers = function(allTiles, completedTiles){
  tileCompleteData().css("visibility", "hidden");
  tileCompletedNum().text(completedTiles);
  tileAll().text(allTiles);
  if(allTiles == completedTiles){
    tileAll().css("display", "none");
  }else{
    tileAll().css("visibility", "hidden");
  }
}

var showTileNumbers = function(allTiles, completedTiles){
  tileAll().css("visibility", "visible");
}

var fillTileBar = function(allTiles, completedTiles){
  var deferred = $.Deferred();

  hideTileNumbers(allTiles, completedTiles);
  newWidth = calculateTileProgressWidth(allTiles, completedTiles);
  tileCompletedBar().animate({width: newWidth}, 750, 'linear', function(){
    tileCompleteData().css("visibility", "visible");
    tileAll().css("visibility", "visible");
    deferred.resolve();
  });

  return deferred.promise();
}

var predisplayAnimations = function(tileData, tilePosting) {
  $.when(tilePosting).then(function() {
    var startingData = $.parseJSON(tilePosting.responseText);
    $('#js-flashes').html(tileData.flash_content);
    //$('#user_points').html(tileData.delimited_starting_points);
    //$('#total_points').html(tileData.delimited_starting_points);
    $('#progress_bar .small_cap').html(tileData.master_bar_point_content);
    //$('#user_tickets').html(tileData.starting_tickets);
    $('#raffle_entries').html(tileData.starting_tickets);
    return $.when( fillTileBar(tileData.all_tiles, tileData.completed_tiles) ).then(function(){
      return $.when(animateCounter('total_points', startingData.starting_points, tileData.ending_points, 0.5)).then(function() {
        return fillBar(startingData.starting_tickets, tileData.ending_tickets, tileData.raffle_progress_bar, tileData.all_tiles_done);
      });
    });
  })
}
