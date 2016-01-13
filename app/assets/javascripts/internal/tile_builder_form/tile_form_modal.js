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
    , submitBtn
  ;

  function enableSubmitBtn(){
    submitBtn.removeAttr("disabled");
  }

  function disableSubmitBtn(){
    submitBtn.addAttr("disabled");
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
      useAjaxModal: true
    });
  }

  function submitSuccess(data) {
    tileManager.updateTileSection(data);
    updateShowMoreDraftTilesButton();
  }

  function initEvents() {
    pickImage.click(function(e){
      e.preventDefault();
      var libraryUrl = $(this).data("libraryUrl");
      imageLibraryModal.open(libraryUrl);
    });

    form.submit(function(e) {
      e.preventDefault();

      var formObj = $(this);
      if(formObj.valid()){
        disableSubmitBtn();
        ajaxHandler.submit(formObj, submitSuccess, enableSubmitBtn);
      }else{
        validator.focusInvalid();
      }
    });
  }

  function initVars() {
    form = $(formSel);
    pickImage = $(pickImageSel);
    submitBtn = form.find("input[type=submit]");
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

  function init(AirboTileManager) {
    initModalObj();
    tileManager = AirboTileManager;
  }

  return {
    init: init,
    open: open,
    openModal: openModal
  }
}());
