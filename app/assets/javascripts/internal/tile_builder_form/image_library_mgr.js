var Airbo = window.Airbo || {};

Airbo.ImageLibraryMgr = (function(){
  var imageMgr
    , library
    , imageFromLibrary
    , imageFromLibraryField
    , librarySelector = ".image_library"
    , imageFromLibraryFieldSelector = "#image_from_library"
    , imageFromLibrarySelector = ".tile_image_block.library"
    , nextPageSelector =  "a[rel='next']";

  function selectedImageFromLibrary() {
    return imageFromLibrary.filter(".selected");
  }


  function setSelectedState(imageBlock) {
    imageFromLibrary.removeClass('selected');
    imageBlock.addClass('selected');
  }

  function clearSelectedImage(){
    imageFromLibraryField.val('');
  }

  function setSelectedImageId(id){
    imageFromLibraryField.val(id);
  }

  function select(imageBlock) {
    var url = imageBlock.data('image-url');
    var imgWidth = imageBlock.data('image-width');
    var imgHeight = imageBlock.data('image-height');
    var id = imageBlock.data('tile-image-id');

    setSelectedImageId(id)
    imageMgr.libraryImageSelected(url, imgWidth, imgHeight, id);
    setSelectedState(imageBlock);
  };

  function selectImageFromLibrary() {
    var id = parseInt(imageFromLibraryField.val());
    if (selectedImageFromLibrary().length === 0 && id > 0) {
      setSelectedState(imageFromLibrary.filter("[data-tile-image-id=" + id + "]"));
    }
  };

  function initImageChooser(){
    $("body").on("click", imageFromLibrarySelector, function(event) {
      event.stopPropagation();
      event.stopImmediatePropagation();
      select($(this));
    });
  }


  function initScrolling() {
    var scrollOnFirstLoad = true;
    library.jscroll({
      loadingHtml: "<img src='" + library.data("loadingImageUrl") + "' />",
      nextSelector: nextPageSelector,
      debug: true,
      padding: 100,
      callback: function() {
        if(scrollOnFirstLoad) {
          scrollOnFirstLoad = false;
          $(".image_library").scrollTop(0);
        }
      }
    } );
  };

  function initjQueryObjects(){
    imageFromLibraryField = $(imageFromLibraryFieldSelector);
    library = $(librarySelector);
    imageFromLibrary =  $(imageFromLibrarySelector);
  }

  function init(mgr){
    imageMgr = mgr;
    initjQueryObjects();
    initImageChooser();
    initScrolling();
    return this;
  };

  return {
    setSelectedImageId: setSelectedImageId,
    clearSelectedImage: clearSelectedImage,
    selectImageFromLibrary: selectImageFromLibrary,
    init: init
  }
}());



