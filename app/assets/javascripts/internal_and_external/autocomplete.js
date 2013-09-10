
var autocomplete_in_progress = 0;
var autocomplete_waiting = 0;
var new_chars_entered = 0;
var delay_before_send = 300; // How long of a delay must exist after typing before we send a request
var watchdog_running = 0;
var last_keypress = 0;

$(function() {
  $('#search_for_referrer #autocomplete').keypress(function(){
      var email = $('#user_email').val();
      var options = {email : email, calling_div : '#search_for_referrer' };
      startWatchDog(options);
      markForSend();
  });

  $('#search_for_friends_to_invite #autocomplete').live('keypress', function(){
      var email = $('#user_email').val();
      var options = {email : email, calling_div : '#search_for_friends_to_invite'};
      startWatchDog(options);
      markForSend();
  });

  $('#search_for_referrer .single_suggestion').live('click', function() {
    stopWatchDog();
    $('#user_game_referrer_id').val($(this).find('.suggested_user_id').text());
    $('#search_for_referrer #autocomplete').hide();
    $('#autocomplete_status').text('');

    $(this).insertAfter('#autocomplete');
    $("#suggestions").html('');
    $("#suggestions").hide();
    //updatePotentialPoints();
  });



  $('.remove_referrer').live('click', function() {
    $('#user_game_referrer_id').val('');
    $(this).parent('.single_suggestion').remove();
    $('#autocomplete').show();
    $('#autocomplete').val('');
    $('#autocomplete').focus();
    if ($('#potential_bonus_points').text() == '0'){
      $('#hide_me_while_selecting').hide();
    }
    //displayPotentialPointsPrepopulated();
    
    return false;
  });
});

function startWatchDog(options){
  if(!watchdog_running){
    watchdog_running = 1;
    watchDogSender(options);
  }else{
  }
}

function stopWatchDog(){
  watchdog_running = 0;
}

function watchDogSender(options){
  // This function repeats every 100ms until we stop the watchdog
  if(watchdog_running){
    autocompleteIfNewCharsEnteredAndNoKeypressesRecently(options);
    setTimeout(function(){watchDogSender(options);}, 100);
  }
}

function autocompleteIfNewCharsEnteredAndNoKeypressesRecently(options){
  if (new_chars_entered &&  noKeypressesRecently()){
    unmarkForSend();
    autocompleteIfNoneRunning(options);
  }
}


function markForSend(){
   new_chars_entered = 1;
   last_keypress = timeNowMS();
}
 
function unmarkForSend(){
   new_chars_entered = 0;
}

function noKeypressesRecently(){
  now = timeNowMS();
  if (now - last_keypress > delay_before_send){
    return true;
  }
  return false;
}

function timeNowMS(){
  time_string = new Date;
  return time_string.getTime();
}


function autocompleteIfNoneRunning(options){
  //Only allow one request at a time
  //Allow queue size of one
  if (autocomplete_waiting){
    //Queue is full, so do nothing
    return false;
  }else if (autocomplete_in_progress){
    //put this one in the queue to try again in one second
    autocomplete_waiting = 1;
    setTimeout(function(){autocompleteIfNoneRunningAndResetQueue(options)}, 1000);

  }else{
    //Nothing is running or waiting, so send the ajax request for autocompletions
    //Note the tiny delay so that the most recent typed letter is included
    autocomplete_in_progress = 1;
    setTimeout(function() {getAutocomplete(options)},50);
  }
}

function autocompleteIfNoneRunningAndResetQueue(options){
  autocomplete_waiting = 0;
  autocompleteIfNoneRunning(options);
}

function getAutocomplete(options){
  var entered_text = $(options['calling_div'] + ' #autocomplete').val();
  if (entered_text.length > 2){
    options['entered_text'] = entered_text;
    $("#autocomplete_status").text('Searching ...');
    $.get('/invitation/autocompletion#index', options, function(data){
      options = {};
      if (data == ''){
        $("#autocomplete_status").text('Hmmm...no match'); 
        $("#suggestions").hide();
         
        setTimeout(function(){
          if ($("#autocomplete_status").text() == 'Hmmm...no match')
          $("#autocomplete_status").text('Please try again');
          }, 3000);    
      }else{        
        $("#autocomplete_status").text('Click on the person you want to invite:');    
        $("#search_for_referrer #autocomplete_status").text('Click on the person who referred you:');    
        $(".helper.autocomplete").fadeOut();
        $("#hide_me_while_selecting").hide();
        $("#bonus").fadeOut(); 
        $("#suggestions").show();
        
        
        
      }
      $("#suggestions").html(data);
      resizeFaceboxToFitSuggestions();
      
      autocomplete_in_progress = 0;
    });
  }else{
     $("#suggestions").html('');
     setTimeout("$('#suggestions').hide()", 1);
     setTimeout('resizeFaceboxToFitSuggestions()', 1); 
     

     // Yes, you must set this to zero even if you didn't run the function call
     autocomplete_in_progress = 0;
     $("#autocomplete_status").text('3+ letters, please');
   }
   if (entered_text.length == 0){
     setTimeout("$('.helper.autocomplete').fadeIn()", 500);
     clearAutocompleteStatus();
   }else{
     setTimeout("$('.helper.autocomplete').fadeOut()", 500);
   }
}

function fadeOutUnclickedSuggestions(){
  $('.single_suggestion').addClass('fade_out_singles');
  $(this).removeClass('fade_out_singles');
  $('.fade_out_singles').fadeOut(1500, resizeFaceboxToFitSuggestions);
}

function resizeFaceboxToFitSuggestions(){
  var show_div = $("#search_for_friends_to_invite");
  var show_div_height = show_div.height();
  var extra = 10;
  var new_height = show_div_height + extra;
  var page_version = $(".invite-module");
  page_version.css("height", new_height);
}
function clearAutocompleteStatus(){
  $('#autocomplete_status').text('');
}

