$(function() {
  //Calls the tocify method on your HTML div.
  support = $("#toc");
  if(support.length > 0){
    support.tocify({context: ".content"});

    editor = $("#support_body_editor");
    if(editor.length > 0){
      params = {
        toolbar: {
          buttons: ['bold', 'italic', 'underline', 'unorderedlist', 'orderedlist', "anchor", 'h1', 'h2', 'h3']
        }
      }
      Airbo.Utils.mediumEditor.init(params);
    }
  }
});
