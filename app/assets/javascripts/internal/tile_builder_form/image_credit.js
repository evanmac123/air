var Airbo = window.Airbo || {};

Airbo.TileImageCredit = (function(){
  var  imageCreditInput, 
  imageCreditView, 
  maxLength = 50, 
  maxLengthAfterTruncation = maxLength + '...'.length, 
  backspaceKeyCode=8;

  function initImageCreditHandlers(){

    imageCreditView.keyup(function() {
      saveImageCreditChanges('keyup');
      truncateImageCreditView();
    });

    imageCreditView.keydown(function(e) {
      if (isStatus('truncated') && e.keyCode === backspaceKeyCode()) {
        setStatus('');
        imageCreditView.text('');
      }
    });

    imageCreditView.click(function() {
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
    return imageCreditView.data("status", status);
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
      return setStatus('truncated');
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

  function init(){

    imageCreditView = $('.image_credit_view');
    imageCreditInput = $('#tile_builder_form_image_credit');

    initImageCreditHandlers();
    saveImageCreditChanges();
    truncateImageCreditView();
  };


  return {
    init: init
  }

}());

$(function(){
  if (Airbo.Utils.isAtPage(Airbo.Utils.Pages.TILE_BUILDER)) {
    Airbo.TileImageCredit.init();
  }
})
