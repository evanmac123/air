var Airbo = window.Airbo || {};

Airbo.ImageSearcher = (function(){
  var self = this
    , grid
    , missingImage = $("#images").data("missing")
    , searchFormSel = ".search-form"
  ;


  var resultHandlers = {
    google: function(data){
      var html = "" ;
      data.items.forEach(function(item){
        var link = item.link
          , img = "<img style='height:150px' src='" + link + "'/>"
          , cell = "<div class='cell'>" + img + "</div>"
        ;

        html += cell;
      });

      togglePaging(data.queries); 
      return html;
    }, 
    pixabay: function(data){
      var html = "" ;
      if (parseInt(data.totalHits) > 0)

        data.hits.forEach(function(item, i){
          var link = item.pageUrl
            , img = "<img src='" + link + "'/>"
            , cell = "<div class='cell'>" + img + "</div>"
          ;

          html += cell;
        });
        return html;
    },

    flickr: function(data){
      var urls = getFlickrImageUrls(data.photos.photo)
        , html = ""
        , thumbnails
        , groups
      ;

      thumbnails = buildImages(urls);

      groups = buildGroups(thumbnails) ;

      html = groups.reduce(function(val,currGrp,i,arr){
        return val +  "<div class='cell-group'>" + currGrp.join("") + "</div>";
      }, "")

      return html;
    }
  }

  function buildGroups(thumbnails){
    var i , j
      , groups = []
      , groupSize = 12
    ;

    for (i=0,j=thumbnails.length; i<j; i += groupSize) {
      groups.push(thumbnails.slice(i, i + groupSize))
    }
    return groups;
  }

  function buildImages(images){
    return  images.map(function(image, i){
      return "<img src='" + image.thumbnail + "' data-preview='" + image.preview + "'/>"
    });
  }

  function getFlickrImageUrls(photos){
    var urls = [] 
      , flickrImageUrlTemplate = "https://farm{farm}.staticflickr.com/{server}/{id}_{secret}"
    ;

    photos.forEach(function(photo){
      var base = flickrImageUrlTemplate.replace(/\{(.*?)\}/g, function(match, token) {
        return photo[token];
      });

      urls.push({
        thumbnail: base + "_q.jpg",
        preview: base + "_c.jpg" 
      });

    });
    return urls;
  }

  function doFlickity(){
    grid.flickity({
      imagesLoaded: true,
      pageDots: false,
    });
    grid.flickity('unbindDrag');
    grid.flickity('resize')
  }

  function processResults(data,status,xhr){
    showSearchResults();
    handler = this.provider;
    var html = handler(data);
    presentData(html);
  }

  function presentData(html){
    if(grid.data('flickity') == undefined){
      grid.html($(html));
      doFlickity();
    }else{
      grid.flickity('remove', grid.flickity('getCellElements'))
      grid.flickity('append', $(html));
    }
  }

  function showVisualContentPanel(){
    $(".visual-content-container").slideDown();
  }

  function showSearchResults() {
    showImageWrapper();
    showVisualContentPanel();
  }

  function hideImageWrapper(){
    $(".images-wrapper").hide();
  }

  function showImageWrapper(){
    $(".images-wrapper").show();
  }

  function showEmbedVideo(){
    $(".embed-video-container").show();
  }

  function hideEmbedVideo(){
    $(".embed-video-container").hide();
  }

  function hideVisualContentPanel(){
    $(".visual-content-container").slideup();
    hideimagewrapper();
    hideEmbedVideo();
  }

  function resetSearchInput(){
    $(".search-input").val("").animate({width:'0px'}, 600, "linear")
  }

  function resetEmbedVideo(){
    $("#embed_video_field").val("");
  }
  function initTriggerImageSearch(){
    $(".search-input").keypress(function(event){
      var keycode = (event.keyCode ? event.keyCode : event.which)
        , form =$("#flickr.search-form")
        , ctx = {}
        , searchField = 'input[name=' + form.data("search-field") +']'
      ;
        if(keycode == '13'){
          ctx.provider = resultHandlers[form.data("provider")]
          form.find(searchField).val($(this).val());
          $.ajax({
            url: form.attr("action"),
            type: form.attr("method"),
            data: form.serialize(),
            dataType: "json",
          })
          .done(processResults.bind(ctx))
          .fail(function(){
          })
        }
    });
  }

  function initShowSearchInput(){
    $("body").on("click", ".show-search", function(event){
      hideEmbedVideo();
      resetEmbedVideo();
     $(".search-input").animate({width:'200px'}, 600, "linear")
    })
  }

  function initShowVideoPanel(){
    $("body").on("click", ".img-menu-item.video", function(event){
      hideImageWrapper();
      resetSearchInput();
      showEmbedVideo();
      showVisualContentPanel();
    });
  }

  function initHideVisualContent(){
    $("body").on("click", ".hide-search", function(event){
      resetSearchInput();
      hideVisualContentPanel();
    });
  }

  function initVisualContent(){
    initHideVisualContent();
    initShowVideoPanel();
    initShowSearchInput();
  }


  function initImagePreview(){
    $("body").on("click","#images img", function(event){
      var img = $(this);
      var props= {url: $(this).data("preview")};

      $.Topic("image-selected").publish(props); 
    });
  }

  function init(){
    grid = $("#images");
    initVisualContent();
    searchForm = $(searchFormSel);
    initTriggerImageSearch()
    initImagePreview();
  }



  return {
    init: init
  };

}())

