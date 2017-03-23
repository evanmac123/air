var Airbo = window.Airbo || {};

Airbo.ImageSearcher = (function(){
  var self = this
    , grid
    , missingImage = $("#images").data("missing")
    , searchFormSel = ".search-form"
    , page = 0
    , flickityObj
    , imageProviderList
    , imageProviders
    , NO_RESULTS = '<p class="err msg"><i class="fa fa-frown-o"></i> Sorry, no images found for your search. Please try a different search.</p>'
    , remoteMediaUrl
  ;

  function initDom(){
    remoteMediaUrl = $('#remote_media_url');
  }

  function setFormFieldsForSelectedImage(url, type, source){
    remoteMediaUrl.val(url);
    $('#remote_media_type').val(type || "image");
    $("#media_source").val(source);
  }

  function doFlickity(){
    grid.flickity({
      lazyLoad: true,
      pageDots: false,
    });

    flickityObj = grid.data('flickity')

    grid.flickity('unbindDrag');

    grid.on( 'select.flickity', function( event, progress ) {
      if(flickityObj.selectedIndex == flickityObj.cells.length -1){
      }
    });
  }

  function processResults(data,status,xhr){
    var handler = this.provider
      , html = handler.handle(data)
    ;

    $.Topic("image-results-added").publish();
    presentData(html);
    $.Topic("media-request-done").publish();
    Airbo.Utils.ping("Image Search", {searchText: this.search, hasResults: (html !==undefined)});
  }

  function presentData(html){
    var isflickity = grid.data('flickity') !== undefined
      , hasResults
    ;

    if(html===undefined){
      if(isflickity){
        grid.flickity('destroy');
      }
      grid.html(NO_RESULTS);
    }else{
      if(isflickity){
        grid.flickity('remove', grid.flickity('getCellElements'))
        grid.flickity('append', $(html));
      }else{
        grid.html($(html));
        doFlickity();
      }
    }

  }

 



  function executeSearch(){
    imageProviders.forEach(function(service){
      var form =$("#"+ service.name + ".search-form")
        , apiSearchField = 'input[name=' + form.data("search-field") +']'
        , searchText = $(".search-input").val()
        , ctx = {provider:  service, search: searchText} // create context binding for the ajax success handler
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
        executeSearch();
      }
    })
  }

  function initSearchFocus(){
    $(".search-input").focusin(function(event){
      $(this).parents(".search").addClass("focused");
    })


    $(".search-input").focusout(function(event){
      $(this).parents(".search").removeClass("focused");
    })
  }

   function initPreviewSelectedImage(){
    $("body").on("click","#images img", function(event){
      var img = $(this);
      var props= {url: $(this).data("preview")};

      $.publish("image-selected", props); 
      setFormFieldsForSelectedImage(props.url,"png", "image-search")
    });
  }


  function loadImageProviders(){
    imageProviderList = $(".search-input").data('services');

    imageProviders = imageProviderList.map(function(service){
      return ImageSearchService.getProvider(service);
    });
  }


  function init(){
    initDom();
    Airbo.TileVisualPreviewMgr.init();
    grid = $("#images");
    searchForm = $(searchFormSel);
    initTriggerImageSearch()
    initPreviewSelectedImage();
    loadImageProviders();
    initSearchFocus();
  }

  return {
    init: init
  };

}())


