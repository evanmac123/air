var Airbo = window.Airbo || {};

$(function() {


  //if (Airbo.Utils.supportsFeatureByPresenceOfSelector("#new_tile_builder_form, #add_new_tile") ) {

  /************************************************
   *
   * Creates a wrapper around the image previewer
   * and the image library modules
   *
   * **********************************************/

    Airbo.TileImagesMgr = (function(){
      var initialized,
      previewer, 
      library,
      noImage, 
      imageContainer,
      remoteMediaUrl,
      remoteMediaType;

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

      function clearImage(){
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
        $('.clear_image').click(function(event) {
          clearImage()
        });
      }

      function initVars(){
        noImage = $('#no_image'), 
          imageContainer = $('#image_container'),
          remoteMediaUrl = $('#remote_media_url'),
          remoteMediaType = $('#remote_media_type');
      }

      function init(){
        if (Airbo.Utils.supportsFeatureByPresenceOfSelector("#new_tile_builder_form, #add_new_tile") ) {
          initVars();
          initClearImage();
          previewer = Airbo.ImagePreviewer.init(this)
          library = Airbo.ImageLibrary.init(this)

          Airbo.DirectToS3ImageUploader.init( {
            processed: showImagePreview,
            done: directUploadCompleted,
            added: showFileName,
          });

          return this;
        }
      }

      function getRemoteMediaURL(){
        return remoteMediaUrl.val();
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

  //}


    Airbo.TileImagesMgr.init();
});
