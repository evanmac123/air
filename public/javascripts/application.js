var autocomplete_in_progress = 0;
var autocomplete_waiting = 0;
var global_contents_of_three_ways_to_play_3838477463535 = '';

$(function() {
  
  saveFaqMiniToVariable();  
  
  $('#invite_friends_link').live('click', function(){
    grabUsersToInvite();
    
    setTimeout("$('#search_for_friends_to_invite form').submit()", 1000);
  });
  

  
  if (document.getElementById('command_central')){
    $('#command_central').focus();
    var sugg = "ate an orange";
    $('#command_central').val(sugg);
    $('#command_central').click(function(){
      $('#command_central').val('');   
    });
    
    $('#command_central').keypress(function(key){
      if (sugg == $('#command_central').val()){
        $('#command_central').val('');
      }
      if (key.keyCode == 13){
       $('#flash_failure').hide();
      }
      $('#command_central').addClass('green');
      
    })
  };


  $('#lots_of_friends').live('click', function(){
    $('.second_half').show();
    $(this).hide();
	$('#facebox,.popup,.content').css("height","500px");
  });
  if (document.getElementById('invite_friends_facebox')){
    $.facebox({ div: '#invite_friends_facebox' });

    if (document.getElementById('email_prepends_0')){
      $('#facebox #email_prepends_0').focus();
      // For now, don't show the invite friends thing on the underlay
      $('#invite_friends_facebox').html('');
      
      // UNCOMMENT the following when you remove the line above
      // var prep = '#email_prepends_';
      // for (var i=0; i<10; i++){ // change these id's so there are no duplicates on the
      //   $('#facebox ' + prep + i).attr('id', prep + i + '_facebox');
      // }

    }else{
      hideAndRenamePageBasedInviteFriends();
      $(document).bind('close.facebox', function() { moveInviteFriendsFaceboxToPage(); });
      $('#facebox #autocomplete').focus();
    }

  }



    
    
  
  
  $('[id^=email_prepends]').blur(function(){
    setTimeout('calculatePoints()', 500);
  });

  $('#search_for_referrer #autocomplete').keypress(function(){
      var email = $('#user_email').val();
      var options = {email : email, calling_div : '#search_for_referrer' };
      autocompleteIfNoneRunning(options);
  });

  $('#search_for_friends_to_invite #autocomplete').live('keypress', function(){
      var email = $('#user_email').val();
      var options = {email : email, calling_div : '#search_for_friends_to_invite'};
      autocompleteIfNoneRunning(options);
  });

  $('#search_for_referrer .single_suggestion').live('click', function() {
    $('#user_game_referrer_id').val($(this).find('.suggested_user_id').text());
    $('#search_for_referrer #autocomplete').hide();
    $('#autocomplete_status').text('');

    $(this).insertAfter('#autocomplete');
    updatePotentialPoints();
  });

  $('#search_for_friends_to_invite .single_suggestion').live('click', function() {
    // var existing_ids = $('#invitee_ids').val();
    // var new_id = $(this).find('.suggested_user_id').text();
    // var new_plus_existing = existing_ids + " " + new_id + ",";
    // $('#invitee_ids').val(new_plus_existing);
    $('#autocomplete').val('');
    $('#autocomplete').focus();
    //$('#search_for_friends_to_invite #autocomplete').hide();
    $(this).insertAfter('#put_selected_users_after_this_div');
    clearAutocompleteStatus();
    setTimeout('$("#suggestions").html("")', 50);
    setTimeout('displayPotentialPointsPrepopulated()', 100);
    
    $("#hide_me_while_selecting").show();
    $("#suggestions").hide();
    setTimeout('resizeFaceboxToFitSuggestions()', 1);
    
  });
  
  $('#facebox .single_suggestion').live('click', function(){
    increasePopupHeight();
  })

  $('.invite-module #search_for_friends_to_invite .single_suggestion').live('click', function() {
  	 var div_to_grow = $('.invite-module');
	 var initial_height = div_to_grow.height();
	 var height_to_add = $('.single_suggestion').height();
	 var new_height = initial_height + height_to_add;
	 div_to_grow.height(new_height);

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
    displayPotentialPointsPrepopulated();
    
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
    setTimeout('$("#suggestions").html("")', 50);
    $('#suggestions').hide();
    clearAutocompleteStatus();
    resizeFaceboxToFitSuggestions();
  });

  resizeFaceboxToFitSuggestions();

});

function saveFaqMiniToVariable(){
  global_contents_of_three_ways_to_play_3838477463535 = $("#faq_mini").html();
  $('#faq_mini').remove();  
}

function fancyBoxFaqMini(){
  // A 100ms delay is given so that if the href is '#', which may take you to the 
  // top of the page, it will wait till you get there before it paints the modal
  setTimeout('$.fancybox(global_contents_of_three_ways_to_play_3838477463535)', 100);
}

function grabUsersToInvite(){
  //grab all the user_ids 
  var invitee_ids = '';
 
  var ids = $.map($('.single_suggestion .suggested_user_id'), function(value){
    invitee_ids += $(value).text() + ', '; 
   
  });
  $('#invitee_ids').val(invitee_ids);
}

function increasePopupHeight(){
	var div_to_grow = $('.popup .content');
	var initial_height = div_to_grow.height();
	var height_to_add = $('.single_suggestion').height();
	var new_height = initial_height + height_to_add;
	div_to_grow.height(new_height);
}

function hideAndRenamePageBasedInviteFriends(){
  $('#invite_friends_facebox').html('');  
  $('#invite_friends_facebox').attr('id', 'temporary_div_name');  
}

function moveInviteFriendsFaceboxToPage(){
  var stuff_in_facebox = $('#facebox .content').html();
  //$('#facebox').remove();
  $('#temporary_div_name').html(stuff_in_facebox); 
  $('#temporary_div_name').attr('id', 'invite_friends');
  $('.autocomplete').css('opacity', 1);
  
}

function calculatePoints(){
  // here we will see how many email addresses were entered and apply points accordingly
  var number_emails = 0;
  var points_per_ref = $('#points_per_referral').text();
  if (points_per_ref == ''){
    $('#bonus').html('This game does not have referral bonuses set up yet.');
  }else{
    points_per_ref = parseInt(points_per_ref);
    var which_div = '';
    var div_contents = '';
    for (var i=0; i<10; i++){
      which_div = 'email_prepends_' + i;
      div_contents = document.getElementById(which_div).value;
      if (div_contents != ''){
        number_emails += 1;
      }
    }
    var total_potential = number_emails * points_per_ref;
    if (total_potential > 0) {
      $('#bonus').show();
    }
    $('#potential_bonus_points').text(total_potential);
  }
}

function displayPotentialPointsPrepopulated(){
  
  var ppr = $('#points_per_referral').text();
  var num_invitees = $('.single_suggestion').length;
  if (num_invitees == 0){
    msg = "Type part of your coworker's name or email, and we'll look them up."
    $('#hide_me_while_selecting').hide();
  }else if (ppr == ''){
    alert('Please email support@hengage.com and ask them to set up bonuses for this game');
  }else{
    ppr = parseInt(ppr);
    $('#potential_bonus_points').text(ppr * num_invitees);
    var pts = ppr * num_invitees;
    var msg = '';
    if (pts > 0){
      msg = "<div class='bigger_message'><span class='gold'>+" + pts + "</span> potential bonus points!</div>Keep going!<br><br>You can add lots of friends to this list and then click 'invite'"; 
    }
    $(".helper.autocomplete").html(msg);
    $('#bonus').show();
  }  
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

function resizeFaceboxToFitSuggestions(){
  var show_div = $("#search_for_friends_to_invite");
  var show_div_height = show_div.height();
  var extra = 10;
  var new_height = show_div_height + extra;
  var facebox_version = $("#facebox .content");
  facebox_version.css("height", new_height);
  var page_version = $(".invite-module");
  page_version.css("height", new_height);
}
function clearAutocompleteStatus(){
  $('#autocomplete_status').text('');
}
