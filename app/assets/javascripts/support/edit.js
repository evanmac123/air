$(function() {
  editor = $("#support_body_editor");
  if(editor.length > 0){
    params = {
      toolbar: {
        buttons: ['bold', 'italic', 'underline', 'unorderedlist', 'orderedlist', "anchor", 'h1', 'h2', 'h3', 'image']
      }
    }
    Airbo.Utils.mediumEditor.init(params);
  }
});
