var Airbo = window.Airbo ||{}


Airbo.ImageCreditIE = (function(){
  var imageCreditView,
  imageCreditInput,
  maxLength = 50,
    imageCreditInputSelector = '#tile_builder_form_image_credit';

  function normalizedImageCreditInput() {
    var inputted_text;
    inputted_text = imageCreditInput.val();


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
    return imageCreditView.html(text);
  }

  function initSelectors(){
    imageCreditView = $('.image_credit_view');
    imageCreditInput=$(imageCreditInputSelector);
  }

  function init(){
    initSelectors();
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

