
Airbo.TileSuportingContentTextManager = (function(){

  var contentEditor
    , contentInput
    , contentEditorSelector = '#supporting_content_editor'
    , contentInputSelector = '#tile_builder_form_supporting_content'
  ;

  function contentEditorMaxlength() {
    return contentEditor.next().attr('maxlength');
  };


  // function blockSubmitButton (counter) {
  //   var errorContainer, submitBtn, textLeftLength;
  //   textLeftLength = contentEditor.text().length;
  //   submitBtn = $("#publish input[type=submit]");
  //   errorContainer = $(".supporting_content_error");
  //   if (textLeftLength > contentEditorMaxlength()) {
  //     submitBtn.attr('disabled', 'disabled');
  //     errorContainer.show();
  //   } else {
  //     submitBtn.removeAttr('disabled');
  //     errorContainer.hide();
  //   }
  // }

  function updateContentInput() {
    contentInput.val(contentEditor.html());
  }

  function initializeEditor() {
    var pasteNoFormattingIE;
    addCharacterCounterFor('#tile_builder_form_headline');
    addCharacterCounterFor(contentEditorSelector);
  };

  function initjQueryObjects(){
    contentEditor = $(contentEditorSelector);
    contentInput = $(contentInputSelector);
  }


  function init(){

    if (Airbo.Utils.supportsFeatureByPresenceOfSelector(contentEditorSelector) ) {
      initjQueryObjects();
      initializeEditor();
      return this;
    }
  }

  return {
    init: init
  }


}());
