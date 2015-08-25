var Airbo = window.Airbo || {};

$(function() {


  /************************************************
   *
   * Creates a wrapper around the image previewer
   * and the image library modules
   *
   * **********************************************/

    Airbo.TileImagesMgr = (function(){
      var initialized
        , previewer
        , library
        , noImage
        , imageContainer
        , remoteMediaUrl
        , remoteMediaType
        , clearImage
        , clearImageSelector = '.clear_image'
        , noImageSelector = '#no_image'
        , imageContainerSelector = '#image_container'
        , remoteMediaUrlSelector = '#remote_media_url'
        , remoteMediaTypeSelector = '#remote_media_type'
      ;

      function imgTypeFromFilename(filename){
        return "image/" + filename.substr(filename.lastIndexOf('.')+1)
      }

      function directUploadCompleted(data,file, filepath){
        updateHiddenImageFields();
        setFormFieldsForSelectedImage(filepath, file.type);
      }

      function libraryImageSelected(url){
        updateHiddenImageFields();
        setFormFieldsForSelectedImage(url, imgTypeFromFilename(url));
        showImagePreview(url);
      }

      function setFormFieldsForSelectedImage(url, type){
        remoteMediaUrl.val(url); 
        remoteMediaType.val(type || "image"); 
      }


      function updateHiddenImageFields() {
        imageContainer.val('');
        noImage.val('');
      };

      function removeImage(){
        updateHiddenImageFields();
        noImage.val('true')
        previewer.clearPreviewImage();
        library.clearSelectedImage();
        remoteMediaUrl.val(undefined)
      }

      function showImagePreview(imgUrl){
        previewer.setPreviewImage(imgUrl);
      }

      function showFileName(file){
        previewer.showFileName(file);
      }

      function initClearImage(){
        clearImage.click(function(event) {
          removeImage();
          event.stopPropagation();
        });
      }

      function initjQueryObjects(){
        noImage = $(noImageSelector);
        imageContainer = $(imageContainerSelector);
        remoteMediaUrl = $(remoteMediaUrlSelector);
        remoteMediaType = $(remoteMediaTypeSelector);
        clearImage = $(clearImageSelector);
      }

      function getRemoteMediaURL(){
        return remoteMediaUrl.val();
      }

      function init(){
        if (Airbo.Utils.supportsFeatureByPresenceOfSelector("#new_tile_builder_form") ) {
          initjQueryObjects();
          initClearImage();

          previewer = Airbo.ImagePreviewer.init(this)
          library = Airbo.ImageLibrary.init(this)
          contentEditor = Airbo.TileSuportingContentTextManager.init(this)
          question = Airbo.TileQuestionBuilder.init();
          points = Airbo.tilePointsSlider.init();

          Airbo.DirectToS3ImageUploader.init( {
            processed: showImagePreview,
            done: directUploadCompleted,
            added: showFileName,
          });

          return this;
        }
      }
     

      return {
        init: init,
        showImagePreview: showImagePreview,
        showFileName: showFileName,
        directUploadCompleted: directUploadCompleted,
        libraryImageSelected: libraryImageSelected, 
        remoteMediaUrl: getRemoteMediaURL,
      };

    }());


    /************************************************
     *
     * Provides the functionality for 
     * interacting with the image library 
     *
     * **********************************************/

    Airbo.ImageLibrary = (function(){
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

      function setSelectedImageId(){
        imageFromLibraryField.val(selectedImageFromLibrary().data('tile-image-id'));
      }

      function select(imageBlock) {
        var url = imageBlock.data('image-url')
        imageMgr.libraryImageSelected(url);
        setSelectedState(imageBlock);
      };

      function selectImageFromLibrary() {
        var id = parseInt(imageFromLibraryField.val());
        if (selectedImageFromLibrary().length === 0 && id > 0) {
          setSelectedState(imageFromLibrary.filter("[data-tile-image-id=" + id + "]"));
        }
      };

      function initImageChooser(){
        $("body").on("click", imageFromLibrarySelector, function() {
          select($(this));
        });
      }


      function initScrolling() {
        library.jscroll({
          loadingHtml: "<img src='" + library.data("loadingImageUrl") + "' />",
          nextSelector: nextPageSelector,
          debug: true,
          padding: 0,
          callback: false 
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


    /************************************************
     *
     * Provides the image preview functionality for 
     * both images selected from the library and 
     * images that are uploaded by the user
     *
     * **********************************************/

    Airbo.ImagePreviewer = (function(){
      var imageMgr, imgPreview;

      function removeImageCredit() {
        $('.image_credit_view').text('').trigger('keyup').trigger('focusout');
      };

      function clearPreviewImage(){
        showPlaceholder();
        removeImageCredit();
        $("#uploaded_image_file").text("Pick an image").removeClass("file_selected")
      }

      function showPlaceholder() {
        imgPreview.removeClass('show_shadows').addClass('show_placeholder');
      };

      function showShadows() {
        imgPreview.removeClass('show_placeholder').addClass('show_shadows');
      };


      function setPreviewImage(imageUrl) {
        showShadows();
        $('#upload_preview').attr("src", imageUrl);
      };

      function showFileName(file){ 
        $("#uploaded_image_file").text(file.name).addClass("file_selected")
      }

      function init(mgr){
        imageMgr = mgr
        imgPreview= $('.image_preview');
        return this;
      }

      return {
        init: init,
        setPreviewImage: setPreviewImage,
        showFileName: showFileName,
        clearPreviewImage: clearPreviewImage 
      };

    })();

Airbo.TileSuportingContentTextManager = (function(){

  var contentEditor
    , contentInput
    , contentEditorSelector = '#supporting_content_editor'
    , contentInputSelector = '#tile_builder_form_supporting_content'
  ;

  function contentEditorMaxlength() {
    return contentEditor.next().attr('maxlength');
  };


  function blockSubmitButton (counter) {
    var errorContainer, submitBtn, textLeftLength;
    textLeftLength = contentEditor.text().length;
    submitBtn = $("#publish input[type=submit]");
    errorContainer = $(".supporting_content_error");
    if (textLeftLength > contentEditorMaxlength()) {
      submitBtn.attr('disabled', 'disabled');
      errorContainer.show();
    } else {
      submitBtn.removeAttr('disabled');
       errorContainer.hide();
    }
  }

  function updateContentInput() {
    contentInput.val(contentEditor.html());
  }

  function initializePenEditor() {
    var options = {
      editor: contentEditor[0],
      list: ['bold', 'italic', 'underline', 'insertorderedlist', 'insertunorderedlist', 'createlink'],
      stay: false
    };
      new Pen(options);
  }

  function editorLength() {
    return contentEditor.html().length;
  };

   function contentEditorModifiedEvents() {
    window.lastEditorLength = editorLength();
    return contentEditor.bind("DOMSubtreeModified", function() {
      if (editorLength() !== window.lastEditorLength) {
        window.lastEditorLength = editorLength();
        blockSubmitButton();
        return updateContentInput();
      }
    });
  };

  function initializeEditor() {
    var pasteNoFormattingIE;
    addCharacterCounterFor('#tile_builder_form_headline');
    addCharacterCounterFor(contentEditorSelector);
    blockSubmitButton();
    initializePenEditor();
    contentEditorModifiedEvents();
    pasteNoFormattingIE = function() {
      var newNode, text;
      text = window.clipboardData.getData("text") || "";
      if (text !== "") {
        if (window.getSelection) {
          newNode = document.createElement("span");
          newNode.innerHTML = text;
          return window.getSelection().getRangeAt(0).insertNode(newNode);
        } else {
          return document.selection.createRange().pasteHTML(text);
        }
      }
    };
    return contentEditor.on('paste', function(e) {
      var text;
      e.preventDefault();
      if (isIE()) {
        return pasteNoFormattingIE();
      } else {
        text = (e.originalEvent || e).clipboardData.getData('text/plain');
        return window.document.execCommand('insertText', false, text);
      }
    });
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

    Airbo.TileImagesMgr.init();
});
