var Airbo = window.Airbo ||{}


Airbo.ImageCreditIE = (function(){
  var maxLength = 50,
    imageCreditView = $('.image_credit_view'),
    imageCreditInputSelector =   '#tile_builder_form_image_credit',
    imageCreditInput =$(imageCreditInputSelector);

  function normalizedImageCreditInput() {
    var inputted_text;
    inputted_text = imageCreditInput().val();
    if (inputted_text !== '') {
      if (inputted_text.length > maxLength()) {
        return inputted_text.substring(0, maxLength()) + '...';
      } else {
        return inputted_text;
      }
    } else {
      return 'Add Image Credit';
    }
  }

  function updateImageCreditView() {
    var text;
    text = normalizedImageCreditInput();
    return imageCreditView().html(text);
  }

  function init(){
    updateImageCreditView();
    addCharacterCounterFor(imageCreditInputSelector);
    imageCreditInput.bind('input propertychange', function() {
      updateImageCreditView();
    });
  }

  return {
    init: init
  };

}());

