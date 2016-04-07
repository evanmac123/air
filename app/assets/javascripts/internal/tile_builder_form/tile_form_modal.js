var Airbo = window.Airbo || {};

Airbo.TileFormModal = (function(){
  // Selectors
  var modalId = "tile_form_modal"
    , formSel ="#new_tile_builder_form"
    , pickImageSel ="#image_uploader"
    , ajaxHandler = Airbo.AjaxResponseHandler
  ;

  var modalObj = Airbo.Utils.StandardModal()
    , tileManager
    , validator
    , form
    , imageLibrary
    , submitLink
  ;

  function enablesubmitLink(){
    submitLink.removeAttr("disabled");
  }

  function disablesubmitLink(){
    submitLink.attr("disabled", "disabled");
  }

  function initFormElements() {
    validator = Airbo.TileFormValidator.init(form);

    Airbo.TileImagesMgr.init();
    Airbo.TileImageCredit.init();
    Airbo.TilePointsSlider.init();
    Airbo.TileQuestionBuilder.init();
    Airbo.TileSuportingContentTextManager.init();
    Airbo.Utils.mediumEditor.init();
    imageLibraryModal = Airbo.ImageLibraryModal;
    imageLibraryModal.init(Airbo.TileFormModal);

    $("#upload_preview").on("load", function(){
      $(".image_preview").removeClass("loading").attr("style", ""); // remove height
    });
  }

  function initModalObj() {
    modalObj.init({
      modalId: modalId,
      useAjaxModal: true,
      confirmOnClose: true,
      modalClass: "bg-user-side",
      onOpenedEvent: function() {
        autosize.update( $('textarea') );
      }
    });
  }

  function submitSuccess(data) {

    tileManager.updateSections(data);

    var tilePreview = Airbo.TilePreviewModal;
    tilePreview.init();
    tilePreview.open(data.preview);
  }

  function initEvents() {
    pickImage.click(function(e){
      e.preventDefault();
      var libraryUrl = $(this).data("libraryUrl");
      imageLibraryModal.open(libraryUrl);
    });

    submitLink.click(function(e){
      e.preventDefault();
      form.submit();
    });

    form.submit(function(e) {
      e.preventDefault();

      var formObj = $(this);
      if(formObj.valid()){
        disablesubmitLink();
        ajaxHandler.submit(formObj, submitSuccess, enablesubmitLink);
      }else{
        validator.focusInvalid();
      }
    });
  }

  function initVars() {
    form = $(formSel);
    pickImage = $(pickImageSel);
    submitLink = form.find(".submit_tile_form");
    // submitBtn = form.find("input[type=submit]");
  }

  function openModal(){
    modalObj.open();
  }

  function open(url) {
    $.ajax({
      type: "GET",
      dataType: "html",
      url: url,
      success: function(data, status,xhr){
        modalObj.setContent(data);
        initVars();
        initEvents();
        initFormElements();
        modalObj.open();
      },

      error: function(jqXHR, textStatus, error){
        console.log(error);
      }
    });
  }

  function init(mgr) {
    initModalObj();
    tileManager = mgr;
  }

  return {
    init: init,
    open: open,
    openModal: openModal
  }
}());
