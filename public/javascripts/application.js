var autocomplete_in_progress = 0;
var autocomplete_waiting = 0;

$(function() {
  $('#search_for_referrer').keypress(function(){
      entered_text = $('#search_for_referrer').val();
      var email = $('#user_email').val();
      var options = {entered_text : entered_text, email : email};
      autocompleteIfNoneRunning(options);
  });
  
  $('.single_suggestion').live('click', function() {
    $('#user_game_referrer_id').val($(this).find('.selected_referrer_id').text());
    
    $('#search_for_referrer').hide();
    $(this).insertAfter('#search_for_referrer');
  });
  
  $('#.remove_referrer').live('click', function() {
    $('#user_game_referrer_id').text('');    
    $('.single_suggestion').hide();
    $('#search_for_referrer').show();
    $('#search_for_referrer').val('');
    return false;
  });  

  $('#add-new-user').live('click', function() {
    $('#new_user').parent('.hidden-form').show();
    $('#user_name').focus();
    return false;
  });

  $('.set-avatar').submit(function(e) {
    $('.set-avatar-submit').attr('disabled', 'disabled');
    $(this).children('.loading-message').show();
  });

  $('.clear-avatar').submit(function(e) {
    if(confirm("Are you sure you want to clear your avatar?") == false) {
      e.preventDefault();
    }
  });

  $('.change-avatar-link').click(function(e) {
    mainProfileHeight = $('#main-profile-section').height();

    $('#main-profile-section').data('original-height', mainProfileHeight);
    $('#main-profile-section').height(mainProfileHeight + $('.avatar-controls').height() + 100);
    $('.avatar-controls').show();
    e.preventDefault();
  });

  $('.with-hint-text').live('focus', (function(e) {
    $(this).attr('value', '').removeClass('with-hint-text');
  }));
  
  
  // These next two are to make the autocompletions disappear if you click on something else
  $('html').click(function() {
    $("#suggestions").html('');
  });

  // $('#suggestions').click(function(event){
  //     event.stopPropagation();
  // });
  
});



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
  var entered_text = $('#search_for_referrer').val(); 
  if (entered_text.length > 2){
    options['entered_text'] = entered_text;
    $.get('/invitation/autocompletion#index', options, function(data){
      options = {};
      $("#suggestions").html(data);
      time_of_last_autocomplete = new Date();
      autocomplete_in_progress = 0;
     });
   }else{
     $("#suggestions").html('');
     // Yes, you must set this to zero even if you didn't run the function call
     autocomplete_in_progress = 0;
   }
}


function lengthInBytes(string) {
  var result = 0;
  for(i = 0; i < string.length; i++) {
    var code = string.charCodeAt(i);
    if(code < 128) {
      result += 0.875;
    } else {
      while(code > 0) {
        result += 1;
        code >>= 8;
      }
    }
  }

  return result;
}

function updateCharacterCounter(from, to) {
  maxLength = $(from).attr('maxlength');
  currentLength = lengthInBytes($(from).val());
  $(to).text('' + ((maxLength * 7 / 8) - currentLength) + ' bytes left');
}

function addByteCounterFor(locator) {
  var ghettoUniqueId = "counter_" + Math.round(Math.random() * 10000000);
  $(locator).after('<span class="character-counter" id="' + ghettoUniqueId + '"></span>');
  updateCharacterCounter(locator, '#'+ghettoUniqueId);
  $(locator).keypress(function() {updateCharacterCounter(locator, '#'+ghettoUniqueId)});
}
