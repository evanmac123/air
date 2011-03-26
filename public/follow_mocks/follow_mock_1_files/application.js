$(function() {
  $('#add-new-user').live('click', function() {
    $('#new_user').parent('.hidden-form').show();
    $('#user_name').focus();
    return false;
  });

  $('.your-mobile-number .change-number-link').click(function(e) {
    $('.your-mobile-number .number').click();
    e.preventDefault();
  });

  $('.your-mobile-number .number').editable(
    '/account/phone', {
      method:   'PUT',
      name:     'user[phone_number]',
      data:     function(value, settings) {
        // This is kind of a hack, since we don't change the data in the form
        // at all, but AFAIK this is the only thing remotely like a pre-edit
        // callback, so our only chance to hide the link.
        $('.your-mobile-number .change-number-link').hide();
        return value;
      },
      callback: function(value, settings) {
        $('.your-mobile-number .change-number-link').show();
      }
  });

  $('.button_to').live('click', function() {
    $(this).hide();
  });
});
