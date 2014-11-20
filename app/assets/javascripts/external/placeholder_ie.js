function supports_input_placeholder() {
  var i = document.createElement('input');
  return 'placeholder' in i;
}
$().ready(function(){
  if (!supports_input_placeholder()) {
    var fields = document.getElementsByTagName('INPUT');
    for (var i = 0; i < fields.length; i++) {
      $(fields[i]).trigger( "focusin" ).trigger( "focusout" );
    }
  }
});
