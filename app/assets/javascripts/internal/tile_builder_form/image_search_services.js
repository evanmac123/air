var ImageSearchServiceFactory = {
  getProvider: function(name){
    var service;

    switch(name){
      case "pixabay":
        service = new PixabayImageHandler();
      break;
      case "giphy":
        service = new GiphyImageHandler();
      break;
    }
    return service;
  }
};

function ImageSearchService() {
  this.totalImages = 0;

  this.buildGroups = function (thumbnails) {
    var groups = [];
    var groupSize = 12;

    for(var i = 0; i < thumbnails.length; i += groupSize) {
      groups.push(thumbnails.slice(i, i + groupSize));
    }

    return groups;
  };

  this.buildHtml = function buildHtml(groups) {
    return groups.reduce(function(val, currGrp, i, arr) {
      return val +  "<div class='cell-group'>" + currGrp.join("") + "</div>";
    }, "");
  };

  this.handle = function(data) {
    var groups;
    var thumbnails = this.buildThumbnails(data);

    if(thumbnails.length > 0) {
      groups = this.buildGroups(thumbnails);
      return this.buildHtml(groups);
    }
    return undefined;
  };
}

//pixabay
function PixabayImageHandler() {
  ImageSearchService.call(this);

  this.name = "pixabay";

  this.url = "https://pixabay.com/api";

  this.setAttribution = function () {
    var attributionHTML = '<a href="http://www.pixabay.com" target="_blank">Powered by<img alt="Pixabay_logo" class="pixabay" src="/assets/pixabay_logo.svg"></a>';

    $(".attribution").html(attributionHTML);
  };

  this.buildThumbnails = function(data) {
    var thumbnails = [] ;
    this.results = parseInt(data.totalHits);
    function getAltSize(item){
      return item.webformatURL.replace("_640", "_180");
    }

    if (this.results > 0){
      thumbnails =  data.hits.map(function(item, i){
        return "<div class='img-wrap'><img src1='" + item.previewURL  + "' data-flickity-lazyload='" + getAltSize(item) +     "' data-preview='" + item.webformatURL +"'/></div>";
      });
    }
    return thumbnails;
  };

  this.data = function(query, key) {
    return {
      "key": key,
      "q": query,
      safesearch: true,
      per_page: 200,
      image_type: "photo"
    };
  };
}

//giphy
function GiphyImageHandler() {
  ImageSearchService.call(this);

  this.name = "giphy";

  this.url = "https://api.giphy.com/v1/gifs/search";

  this.setAttribution = function () {
    var attributionHTML = '<a href="http://www.giphy.com" target="_blank"><img alt="Giphy" style="width:105px;" src="/assets/giphy_attribution.png"></a>';

    $(".attribution").html(attributionHTML);
  };

  this.buildThumbnails = function(data) {
    var thumbnails = [];

    if(this.data.length > 0) {
      thumbnails = data.data.map(function(gif) {
        return "<div class='img-wrap'><img data-flickity-lazyload='" + gif.images.fixed_width_still.url + "' data-preview='" + gif.images.original.url + "'/></div>";
      });
    }

    return thumbnails;
  };

  this.data = function(query, key) {
    return {
      api_key: key,
      q: query,
      limit: 200,
      rating: "g"
    };
  };
}
