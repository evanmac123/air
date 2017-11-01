var Airbo = window.Airbo || {};

Airbo.ImageSearcher = (function(){
  var imageProvider;
  var defaultImageProvider = "pixabay";
  var NO_RESULTS = '<p class="err msg">Sorry, no images found for your search. Please try a different search.</p>';

  function presentData(html) {
    var grid = $("#images");
    var isflickity = grid.data('flickity') !== undefined;
    var hasResults;

    if(html === undefined){
      if(isflickity) {
        grid.flickity('destroy');
      }
      grid.html(NO_RESULTS);
    } else {
      if(isflickity) {
        grid.flickity('remove', grid.flickity('getCellElements'));
        grid.flickity('append', $(html));
      } else {
        grid.html($(html));
        doFlickity(grid);
      }
    }
  }

  function doFlickity(grid){
    grid.flickity({
      lazyLoad: true,
      pageDots: false,
    });

    var flickityObj = grid.data('flickity');

    grid.flickity('unbindDrag');

    grid.on( 'select.flickity', function( event, progress ) {
      if(flickityObj.selectedIndex == flickityObj.cells.length -1){
      }
    });
  }

  function processResults(data, status, xhr){
    var html = this.imageProvider.handle(data);

    Airbo.PubSub.publish("image-results-added");
    presentData(html);

    imageProvider.setAttribution();
    Airbo.PubSub.publish("media-request-done");
    Airbo.Utils.ping("Image Search", { searchText: this.query, hasResults: (html !== undefined) });
  }

  function executeSearch() {
    var imageProviderKey = $(".image-provider-data").data(imageProvider.name);
    var searchText = $(".search-input").val();
    var context = { imageProvider:  imageProvider, query: searchText };

    Airbo.PubSub.publish("inititiating-image-search");

    $.ajax({
      url: imageProvider.url,
      type: "GET",
      data: imageProvider.data(searchText, imageProviderKey),
      dataType: "json"
    }).done(processResults.bind(context));
  }

  function initTriggerImageSearch(){
    $(".show-search").click(function(event){
      executeSearch();
    });

    $(".search-input").keypress(function(event) {
      var keycode = (event.keyCode ? event.keyCode : event.which) ;

      if(keycode == '13'){
        executeSearch();
      }
    });
  }

  function initSearchFocus(){
    $(".search-input").focusin(function(event){
      $(this).parents(".search").addClass("focused");
    });

    $(".search-input").focusout(function(event){
      $(this).parents(".search").removeClass("focused");
    });
  }

   function initPreviewSelectedImage(){
    $("body").on("click","#images img", function(event){
      var img = $(this);
      var props = { url: $(this).data("preview"), source: 'image-search' };
      Airbo.PubSub.publish("image-selected", props);
    });
  }

  function loadImageProvider(){
    var imageProviderName = $(".search-input").data('image-search-service');
    setImageProvider(imageProviderName);
  }

  function currImageProvider() {
    return imageProvider.name;
  }

  function setImageProvider(providerName) {
    var newProvider = ImageSearchServiceFactory.getProvider(providerName);

    if(currImageProvider !== providerName && newProvider !== undefined) {
      imageProvider = newProvider;
    } else {
      console.warn("Image provider could not be changed.");
    }
  }

  function setDefaultImageProvider() {
    setImageProvider(defaultImageProvider);
  }

  function init(){
    Airbo.TileVisualPreviewMgr.init();
    initTriggerImageSearch();
    initPreviewSelectedImage();
    loadImageProvider();
    initSearchFocus();
  }

  return {
    init: init,
    setImageProvider: setImageProvider,
    currImageProvider: currImageProvider,
    setDefaultImageProvider: setDefaultImageProvider,
    executeSearch: executeSearch
  };

}());
