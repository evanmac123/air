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
          , img = "<img src='" + link + "'/>"
          , item = "<div class='cell'>" + img + "</div>"
        ;

        html += item;
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
            , item = "<div class='cell'>" + img + "</div>"
          ;

          html += item;
        });
    }

  }

  function togglePaging(pages){
    if(pages.nextPage !== undefined){
      next = pages.nextPage[0];
      $("#next").data("start",next.startIndex).show(); 
    }

    if(pages.previousPage !== undefined){
      prev = pages.previousPage[0];
      $("#prev").data("start",prev.startIndex).show(); 
    }
  }

  function doMasonry(){
    grid.masonry({
      itemSelector: '.cell',
      isAnimated: true,
      gutter: 20,
      fitWidth: true
    });
  }

  function processResults(data,status,xhr){
    var msnry = Masonry.data( $('#images')[0] )

    handler = this.provider;

    if(msnry !== undefined){
      grid.masonry("destroy");
      grid.empty();
    }

    var html = handler(data);
    grid.html($(html));
    grid.imagesLoaded(function(){
      doMasonry();
      grid.masonry("layout");
    });
  }

  function initPaging(){
    $(".paging").click(function(event){
      event.preventDefault();
     searchForm.find("input[name='start']").val($(this).data("start"));
      searchForm.submit();
    })
  }

  function initSearchForm(){
    searchForm.submit(function(event){
      event.preventDefault();
      var form = $(this);
      var  ctx = {
        provider: resultHandlers[form.data("provider")]
      };

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

  function initImageError(){
    $(".results img").on("error", function(event){
      $(this).attr("src", $("#images").data("missing"));
    });
  }

  function initImagePreview(){
    $("body").on("click",".results img", function(event){
      var img = $(this);
      var props= {url: $(this).attr("src"),h:img.height, w: img.width};
      $.Topic("image-selected").publish(props); 
    });
  }

  function init(){
    grid = $("#images");
    searchForm = $(searchFormSel);
    initSearchForm()
    initPaging();
    initImagePreview();
  }




  return {
    init: init
  };


}())

