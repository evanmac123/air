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
    grid.flickity('resize')
  }

  function processResults(data,status,xhr){
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



  function initPaging(){
    $(".paging").click(function(event){
      event.preventDefault();
      searchForm.find("input[name='start']").val($(this).data("start"));
      searchForm.submit();
    })
  }

  function initImageSearchBar(){
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

  function buildPlaceholders(){
    var html= "<div class='cell-group'>" 
    for(var i=0; i<4; i++){
      html+= "<div class='thumb-placeholder'></div>";
    }
    grid.html( $(html + "</div>"));
  }

  function initImagePreview(){
    $("body").on("click","#images img", function(event){
      var img = $(this);
      var props= {url: $(this).data("preview")};

      $.Topic("image-selected").publish(props); 
    });
  }

  function initToggleSearch(){
    $("body").on("click", ".hide-search", function(event){
      $(".image-search-container").slideUp();
    })

    $("body").on("click", ".show-search", function(event){
      $(".image-search-container").slideDown();
    })
  }

  function init(){
    grid = $("#images");
    initToggleSearch();
    searchForm = $(searchFormSel);
    initImageSearchBar()
    initPaging();
    initImagePreview();
    buildPlaceholders();
  }



  return {
    init: init
  };

}())

