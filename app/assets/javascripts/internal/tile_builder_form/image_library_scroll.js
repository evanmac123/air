var addTileImages, nextSelector, updateNextPageLink;

nextSelector = function() {
  return ".pagination a[rel='next']";
};

addTileImages = function(tileImagesString) {
  var i, len, results, tileImage, tileImages;
  tileImages = $.parseJSON(tileImagesString);
  results = [];
  for (i = 0, len = tileImages.length; i < len; i++) {
    tileImage = tileImages[i];
    results.push($(".tile_images").append(tileImage));
  }
  return results;
};

updateNextPageLink = function(link) {
  if (link) {
    return $(nextSelector()).attr("href", link);
  } else {
    return $(nextSelector()).remove();
  }
};

window.imageLibraryScroll = function(imagePath) {
  return $('.image_library').jscroll({
    loadingHtml: "<img src='" + imagePath + "' />",
    padding: 100,
    nextSelector: nextSelector(),
    pagingSelector: ".paginator",
    callback: function(data) {
      addTileImages(data.tileImages);
      updateNextPageLink(data.nextPageLink);
      return Airbo.ImageLibrary.selectImageFromLibrary();
    }
  });
};
