var ImageSearchService = {
  buildGroups: function (thumbnails){
    var i
      , j
      , groups = []
      , groupSize = 12
    ;

    for (i=0,j=thumbnails.length; i<j; i += groupSize) {
      groups.push(thumbnails.slice(i, i + groupSize))
    }
    return groups;
  },

  buildHtml: function buildHtml(groups){
    return groups.reduce(function(val,currGrp,i,arr){
      return val +  "<div class='cell-group'>" + currGrp.join("") + "</div>";
    }, "");

  },

  handle: function(data){
    var groups
      , thumbnails = this.buildThumbnails(data)
    ;

    if(thumbnails.length > 0){
      groups = this.buildGroups(thumbnails) ;
      return this.buildHtml(groups);
    }
    return undefined;
  },

  getProvider: function(name){
    var service;

    switch(name){
      case "flickr":
        service = FlickrImageHandler;
      break;
      case "pixabay":
        service = PixabayImageHandler;
      break;
    }
    return service;
  },

  totalImages: 0

};

var PixabayImageHandler = Object.create(ImageSearchService)
  , FlickrImageHandler = Object.create(ImageSearchService)
  , GoogleImageHandler =  Object.create(ImageSearchService)
;

PixabayImageHandler.name = "pixabay";
FlickrImageHandler.name = "flickr";
GoogleImageHandler.name = "google";

//pixabay

PixabayImageHandler.buildThumbnails = function(data){
  var thumbnails = [] ;
  this.results = parseInt(data.totalHits)

  if (this.results > 0){
    thumbnails =  data.hits.map(function(item, i){
      return "<img src1='" + item.previewURL  + "' data-flickity-lazyload='" + item.previewURL +     "' data-preview='" + item.webformatURL +"'/>"
    });
  }
  return thumbnails;
}


//flickr

FlickrImageHandler.buildThumbnails = function(data){
  var images = this.getImageUrls(data.photos.photo)
  return  images.map(function(image, i){
    return "<img src='" + image.thumbnail + "' data-preview='" + image.preview + "'/>"
  });
}

FlickrImageHandler.getImageUrls = function(photos){
  var flickrImageUrlTemplate = "https://farm{farm}.staticflickr.com/{server}/{id}_{secret}"
    , urls = [] 
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

//google

GoogleImageHandler.buildThumbnails = function(data){

  return data.items.map(function(item){
    "<img style='height:150px' data-flickity-lazyload='" + item.link + "'/>"
  });
};


