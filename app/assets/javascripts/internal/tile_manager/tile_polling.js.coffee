stillProcessing = (imageStatus) ->
  imageStatus.stillProcessing

selectorForImage = (updateData) ->
  switch updateData.type
    when 'image' then '.tile_image'
    when 'thumbnail' then ("[data-tile_id='" + updateData.id + "'] img")
    when 'tileImageThumbnail' then ("[data-tile-image-id='" + updateData.id + "'] img")

updateSingleImage = (updateData) ->
  $(selectorForImage(updateData)).attr('src', updateData.imageURL)
  if updateData.type == 'image'
    $(selectorForImage(updateData)).css "height", (updateData.imageHeight + "px")

updateTileImagesIfProcessed = (data) ->
  readyToUpdate = _.reject(data, stillProcessing)
  _.each(readyToUpdate, updateSingleImage)
  
  if _.some(data, stillProcessing)
    window.continueTileImagePolling = true

thumbnailRequestUrl = (ids) ->
  '/thumbnails?tile_ids=' + ids

tileImageThumbnailRequestUrl = (ids) ->
  '/thumbnails?tile_image_ids=' + ids

pollURL = (requestedTile) ->
  switch requestedTile.type
    when "image" then "/client_admin/tiles/" + requestedTile.id + "/image.json"
    when "thumbnails" then thumbnailRequestUrl(requestedTile.id)
    when "tileImageThumbnails" then tileImageThumbnailRequestUrl(requestedTile.id)

pollForTileData = (requestedTile) ->
  _pollURL = pollURL(requestedTile)
  ->
    if window.continueTileImagePolling
      window.continueTileImagePolling = false
      $.get(_pollURL, {}, updateTileImagesIfProcessed, 'json')

startTileImagePolling = (requestedTile, timeout) ->
  window.continueTileImagePolling = true
  setInterval pollForTileData(requestedTile), timeout

makeThumbnailRequestfromIds = (ids, type) ->
  {type: type, id: ids.join(',')}

startTileThumbnailPollingFromQueue = (timeout, type = 'thumbnails') ->
  if !(window.thumbnailPollingQueue?)
    return

  thumbnailRequest = makeThumbnailRequestfromIds(window.thumbnailPollingQueue, type)
  window.continueTileImagePolling = true
  setInterval pollForTileData(thumbnailRequest), timeout

queueTileForThumbnailPolling = (tileId) ->
  window.thumbnailPollingQueue ?= []
  window.thumbnailPollingQueue.push(tileId)

window.queueTileForThumbnailPolling = queueTileForThumbnailPolling
window.startTileImagePolling = startTileImagePolling
window.startTileThumbnailPollingFromQueue = startTileThumbnailPollingFromQueue