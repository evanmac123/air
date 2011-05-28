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

/*  $('.change-number-link').click(function(e) {*/
    //$('.number').click();
    //e.preventDefault();
  //});

/*  $('.number').editable(*/
    //'/account/phone', {
      //method:   'PUT',
      //name:     'user[phone_number]',
      //data:     function(value, settings) {
        //// This is kind of a hack, since we don't change the data in the form
        //// at all, but AFAIK this is the only thing remotely like a pre-edit
        //// callback, so our only chance to hide the link.
        //$('.change-number-link').hide();
        //return value;
      //},
      //callback: function(value, settings) {
        //$('.change-number-link').show();
      //}
  /*});*/
});
