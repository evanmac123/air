var Airbo = window.Airbo || {};

Airbo.TileImageCredit = (function(){
  var  imageCreditInput 
    , imageCreditView
    , imageCreditViewSelector ='.new_tile_builder_form .image_credit_view'
    , imageCreditInputSelector ='#tile_builder_form_image_credit'
    , maxLength = 50 
    , maxLengthAfterTruncation = maxLength + '...'.length 
    , backspaceKeyCode=8
  ;

  function initImageCreditHandlers(){

    imageCreditView.keyup(function(event) {
      saveImageCreditChanges('keyup');
      truncateImageCreditView();
    });

    imageCreditView.keydown(function(e) {
      if (isStatus('truncated') && e.keyCode === backspaceKeyCode) {
        setStatus('');
        imageCreditView.text('');
      }
    });

    imageCreditView.click(function(event) {
      event.stopImmediatePropagation();
      if (isStatus('empty')) {
        imageCreditView.text('').focus();
      }
    });

    imageCreditView.focusout(function() {
      if (isStatus('empty')) {
        imageCreditView.text('Add Image Credit');
      }
    });

    imageCreditView.bind('paste', function() {
      imageCreditView.text('');
      setStatus('');
    });

  }


  function isTooLong() {
    return imageCreditView.text().length > maxLengthAfterTruncation;
  };

  function truncate() {
    imageCreditView.text(imageCreditView.text().substring(0, maxLength) + '...');
  };

  function getStatus() {
    return imageCreditView.data("status");
  };

  function setStatus(status) {
    imageCreditView.data("status", status);
  };

  function isStatus(status) {
    return getStatus() === status;
  };

  function hasTextInimageCreditView() {
    return imageCreditView.text().replace(/\s+/g, '').length > 0;
  };

  function truncateImageCreditView() {
    if (!isStatus('truncated') && isTooLong()) {
      truncate();
      setStatus('truncated');
    }
  };

  function saveImageCreditChanges(caller) {
    var text;
    if (!hasTextInimageCreditView()) {
      setStatus('empty');
      text = '';
      if (!imageCreditView.is(':focus') && caller !== 'keyup') {
        imageCreditView.text('Add Image Credit');
      }
    } else if (isStatus('truncated')) {
      text = imageCreditInput.text();
    } else if (hasTextInimageCreditView()) {
      setStatus('');
      text = imageCreditView.text();
    }
    return imageCreditInput.text(text);
  };

  function initImageCreditText() {
    var initText = imageCreditInput.text();
    imageCreditView.text(initText);
  }

  function init(){
    imageCreditView = $(imageCreditViewSelector);
    imageCreditInput = $(imageCreditInputSelector);
    initImageCreditText();

    initImageCreditHandlers();
    truncateImageCreditView();
  }


  return {
    init: init
  }

}());
