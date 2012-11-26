$(function() {
  // Anything in here gets called onload

  $('#no_thanks_tutorial').live('click', function(){
    noThanksTutorial();
  });

  $('.close_tutorial').live('click', function(){
    closeTutorial();
  });
  
  $('#finish_tutorial_button').live('click', function(){
    finishTutorial();
  });
  
  $('#gear').click(function(){
    showMenu();
  });
  
});
// Increase talking_chicken_speed to make the chicken appear snappier
// Also note that in 
// app/assets/javascripts/internal/jumbled_mix_of_things#LaunchTutorialIntroduction
// is where you set the speed of the introductory slide
var talking_chicken_speed = 1.5; // Adjust just this one and everything will scale
var overlay_fade_in_time_ms = 1200.0/talking_chicken_speed;
var highlight_delay_ms = 1000.0/talking_chicken_speed;
var highlight_fade_in_speed = 700.0/talking_chicken_speed;


  //This function removes overlay to free the UI
function spotlightOff() {
 $('.overlaying').animate({
        opacity: 0
    }, 100, function () {
        $('.overlaying').removeClass('overlay');
    });
}

//This function adds an overlay on the UI and add a
//white background to the html element id passed as an argument in the func
function spotlightOn(element) {
    $(element).addClass('spotlight');
    $('.overlaying').addClass('overlay');

    
    
    $('.overlay').fadeIn(overlay_fade_in_time_ms, function(){
      //Force the opacity level for IE7/8 as soon as it's done fading in
      $('.overlay').css('filter', "alpha(opacity='81')"); 
    });

}

function displayToolTip(trigger, display, x, y, reference){
  var highlighted = $(trigger);
  var wall_tooltip = highlighted.tooltip({ // binding the tooltip to the html element with id = wall
          tip: display,
          effect: 'fade',
          fadeInSpeed: highlight_fade_in_speed,
          fadeOutSpeed: 100,
          predelay: 400,
          delay: 100000000,
          offset: [y, x],
          position: reference,
          api: true
  });


  if (wall_tooltip === undefined){
    //do nothing
  }else{
    spotlightOn(highlighted);    
    setTimeout(function(){
      wall_tooltip.show() 
    }, highlight_delay_ms);
  }
}

function hideToolTip(){
  $('#black_tooltip').toggle();
}

function noThanksTutorial(){
  $.fancybox.close();
  var options = { _method : "put", tutorial_request : "no_thanks" };
  $.post('tutorial', options);
  mixpanelPagePingForActivityFeed();
}

function closeTutorial(){
  spotlightOff();
  hideToolTip();
  var options = { _method : "put", tutorial_request : "close" };
  $.post('tutorial', options);
}

function finishTutorial(){
  spotlightOff();
  hideToolTip();
  var options = { _method : "put", tutorial_request : "finish" };
  $.post('/tutorial', options);
}

function showMenu(){
  var gear = $('#gear');
  var options = $('#options');
  options.show();
  gear.hide();
  $('#tutorial_menu').mouseleave(function(){
    options.hide();
    gear.show();
  });
}
    
