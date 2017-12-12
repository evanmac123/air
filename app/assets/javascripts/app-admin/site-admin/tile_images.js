window.tileImages = function() {
  return $("#tile_image_image").change(function() {
    return $("form#new_tile_image").submit();
  });
};
