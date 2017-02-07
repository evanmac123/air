var Airbo = window.Airbo || {};

Airbo.ImageSearcher = (function(){
  var self = this
    , grid
    , missingImage = $("#images").data("missing")
    , searchFormSel = ".search-form"
    , page = 0
    , flickityObj
  ;


  function doFlickity(){
    grid.flickity({
      pageDots: false,
    });

    flickityObj = grid.data('flickity')

    grid.flickity('unbindDrag');

    grid.on( 'select.flickity', function( event, progress ) {
      console.log("index " + flickityObj.selectedIndex)
    })
  }

  function processResults(data,status,xhr){
    $.Topic("image-results-added").publish();
    handler = this.provider;
    var html = handler.handle(data);
    presentData(html);
  }

  function presentData(html){
    if(flickityObj == undefined){
      grid.html($(html));
      doFlickity();
    }else{
      grid.flickity('remove', grid.flickity('getCellElements'))
      grid.flickity('append', $(html));
    }
    console.log("length" + flickityObj.cells.length)
  }


  function hideVisualContentPanel(){
    $(".visual-content-container").slideUp();
    hideImageWrapper();
    hideEmbedVideo();
    $(".hide-search").hide();
  }

  function executeSearch(services){
    services.forEach(function(service){
      var form =$("#"+ service + ".search-form")
        , apiSearchField = 'input[name=' + form.data("search-field") +']'
        , searchText = $(".search-input").val()
        , ctx = {provider:  ImageSearchService.getProvider(service)} // create context binding for the ajax success handler
      ;

      $.Topic("inititiating-image-search").publish();

      form.find(apiSearchField).val(searchText);

      $.ajax({
        url: form.attr("action"),
        type: form.attr("method"),
        data: form.serialize(),
        dataType: "json",
      })
      .done(processResults.bind(ctx))
      .fail(function(){
      })
    });
  }

  function initTriggerImageSearch(){
    $(".show-search").click(function(event){
      executeSearch();
    });

    $(".search-input").keypress(function(event){
      var keycode = (event.keyCode ? event.keyCode : event.which) ;

      if(keycode == '13'){
        executeSearch($(this).data('services') || "pixabay");
      }
    })
  }


  function initPreviewSelectedImage(){
    $("body").on("click","#images img", function(event){
      var img = $(this);
      var props= {url: $(this).data("preview")};

      $.Topic("image-selected").publish(props); 
    });
  }

  function init(){
    Airbo.TileVisualPreviewMgr.init();
    grid = $("#images");
    searchForm = $(searchFormSel);
    initTriggerImageSearch()
    initPreviewSelectedImage();
  }

  return {
    init: init
  };

}())


