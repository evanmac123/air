var Airbo = window.Airbo || {};

Airbo.ImageSearcher = (function(){
  var self = this
    , grid
    , missingImage = $("#images").data("missing");
  ;

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

  function resultsHandler(data,status,xhr){
    var html = "" ;
    var msnry = Masonry.data( $('#images')[0] )
    if(msnry !== undefined){
      grid.masonry("destroy");
      grid.empty();
    }

    data.items.forEach(function(item){
      var link = item.link
        , img = "<img src='" + link + "'/>"
        , item = "<div class='cell'>" + img + "</div>"
      ;

      html += item;

    });

    grid.html($(html));
    initImageError();
    grid.imagesLoaded(function(){
      doMasonry();
      grid.masonry("layout");
    });
    togglePaging(data.queries); 
  }

  function initPaging(){
    $(".paging").click(function(event){
      event.preventDefault();
      $("#search-form").find("input[name='start']").val($(this).data("start"));
      $("#search-form").submit();
    })
  }

  function initSearchForm(){
    $("#search-form").submit(function(event){
      event.preventDefault();
      var form = $(this);
      var $grid;
      $.ajax({
        url: form.attr("action"),
        type: form.attr("method"),
        data: form.serialize(),
        dataType: "json"
      })
      .done(resultsHandler.bind(self))
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
    initSearchForm()
    initPaging();
    initImagePreview();
  }

  return {
    init: init
  };
}())

