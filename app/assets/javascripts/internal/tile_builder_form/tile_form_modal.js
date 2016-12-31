var Airbo = window.Airbo || {};

Airbo.TileFormModal = (function(){
  // Selectors
  var modalId = "tile_form_modal"
    , formSel ="#new_tile_builder_form"
    , pickImageSel =".image_placeholder, .image_preview.show_shadows"
    , ajaxHandler = Airbo.AjaxResponseHandler
    , self
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

  function tileContainerSizes() {
    tileContainer = $(".tile_holder_container")[0];
    if( !tileContainer ) {
      return null;
    }
    return tileContainer.getBoundingClientRect();
  }

  function setTileCreationPingProps(){
    var props =$.extend({}, Airbo.currentUser, {pseudoTileId: Airbo.currentUser.id + "-" + Date.now() });
    $("#pseudo_tile_id").data("props", props);
  }

  function triggerMixpanelTileCreateDurationTracking(){
    setTileCreationPingProps();
    Airbo.Utils.ping("Tile Creation", getTileCreationPingProps("start"));
  }

  function getTileCreationPingProps(step){
    return $.extend({"action": step}, $("#pseudo_tile_id").data("props"));
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
    Airbo.StickyMenu.init(self);
    Airbo.EmbedVideo.initForm();

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
      closeSticky: true,
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
    form.on("click", pickImageSel, function(e){
      e.preventDefault();
      Airbo.Utils.ping("Tile Creation", getTileCreationPingProps("add image"));
      var libraryUrl = $("#image_uploader").data("libraryUrl");
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
        Airbo.Utils.ping("Tile Creation", getTileCreationPingProps("save"));
        ajaxHandler.submit(formObj, submitSuccess, enablesubmitLink);
      }else{
        validator.focusInvalid();
      }
    });
  }

  function initVars() {
    form = $(formSel);
    submitLink = form.find(".submit_tile_form");
  }

  function openModal(){
    modalObj.open();
  }

  function updateThumbnail(data){
    tileManager.updateSections(data);
  }

  function autoSaveSuccess(data){
    updateThumbnail(data)
    enablesubmitLink();
  }

  function initAutoSave(){

    $(form).on("change", function() {
      if(form.valid()){
        disablesubmitLink()
        ajaxHandler.submit(form, autoSaveSuccess, $.noop);
      }
    });

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
        triggerMixpanelTileCreateDurationTracking();
        initAutoSave();
      },

      error: function(jqXHR, textStatus, error){
        console.log(error);
      }
    });
  }

  function init(mgr) {
    self = this;
    initModalObj();
    tileManager = mgr;
    Airbo.EmbedVideo.init();
  }

  return {
    init: init,
    open: open,
    openModal: openModal,
    tileContainerSizes: tileContainerSizes,
    modalId: modalId
  }
}());
