// If you think this file is bad, you should have seen it before I worked on 
// it. --Phil, 9/11/2013.

$(function() {
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

  resizeFaceboxToFitSuggestions();

  $("#search_for_referrer .single_suggestion").live('click', fadeOutUnclickedSuggestions);

  $('.nav-contact-us').click(function(e){
    e.preventDefault();
    $('#IntercomDefaultWidget').click(); 
  });
});

function autoFocusColor(field, text){
  // Define Selectors
  field = $(field);
  
  // color class to add to suggestion text
  var color_class = 'grey';
  
  // Autofocus on the field
  field.focus();
  field.val('email');
  field.addClass(color_class);
  
  // Clear default text when typing
  field.keypress(function(key){
    if (text == field.val()){
      field.val('');
    }
    field.removeClass(color_class);
  })

  // Clear default text when clicked
  field.click(function(){
    if (field.val() == text){
      field.val('');          
    }
  });
  
  // Put default text up when you leave the field if nothing entered
  field.blur(function(){
    if (field.val() == ''){
      field.val(text);
      field.addClass(color_class);          
    }
  });
}
