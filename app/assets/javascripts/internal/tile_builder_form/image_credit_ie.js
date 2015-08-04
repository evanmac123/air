var imageCreditInput, imageCreditInputSelector, imageCreditView, maxLength, normalizedImageCreditInput, updateImageCreditView;

maxLength = function() {
  return 50;
};

imageCreditView = function() {
  return $('.image_credit_view');
};

imageCreditInputSelector = function() {
  return '#tile_builder_form_image_credit';
};

imageCreditInput = function() {
  return $(imageCreditInputSelector());
};

normalizedImageCreditInput = function() {
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
};

updateImageCreditView = function() {
  var text;
  text = normalizedImageCreditInput();
  return imageCreditView().html(text);
};

window.imageCreditIE = function() {
  $(document).ready(function() {
    updateImageCreditView();
    return addCharacterCounterFor(imageCreditInputSelector());
  });
  return imageCreditInput().bind('input propertychange', function() {
    return updateImageCreditView();
  });
};
