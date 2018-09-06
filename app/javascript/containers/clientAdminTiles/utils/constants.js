export default {
  TILE_STATUS: {
    user_submitted: 'Suggested',
    plan: 'Plan',
    draft: 'Proof',
    // share: 'Send',  // Commented out until it is ready to be overhauled into Edit
    active: 'Live',
    archive: 'Archive',
  },
  STATUS_CYCLE: {
    user_submitted: 'plan',
    plan: 'draft',
    draft: 'plan',
    active: 'archive',
    archive: 'active',
  },
  MENU_OPTS: {
    copy: {
      method: 'POST',
      url: 'copy_tile',
      onSuccess: (tileManager, resp) => { tileManager.addTileToCollection(resp[0], {setLoadingTo: false}); },
    },
    deleteConfirm: {
      method: 'DELETE',
      url: 'destroy_tile',
      onSuccess: tileManager => { tileManager.removeTileFromCollection(); },
    },
  },
  UNASSIGNED_CAMPAIGN: {label: 'Unassigned', className: 'campaign-option', value: '0', color: '#fff'},
  MENU_ALERT_OPTS: {
    post: {
      title: 'Are you sure about that?',
      body: 'Tiles are posted automatically when they are delivered. If you manually post a Tile, it will not appear in your next Tile Digest.',
      onConfirmAction: (tile, component) => { component.changeTileStatus(tile, 'active'); },
    },
    delete: {
      title: 'Deleting a tile cannot be undone',
      body: 'Are you sure you want to delete this tile?',
      onConfirmAction: (tile, component) => { component.handleMenuAction(tile, 'deleteConfirm'); },
    },
  },
  NAV_BUTTONS: [{
      faIcon: 'download',
      text: 'Download Stats',
      classList: 'download-stats-button js-download-stats-button button outlined icon',
      tooltip: 'Download Excel file with statistics for all of the Tiles in this section.',
      statusDisplay: ['active', 'archive'],
    },
    {
      faIcon: 'users',
      text: 'Manage Access',
      classList: 'js-suggestion-box-manage-access button outlined icon',
      statusDisplay: ['user_submitted'],
    },
    {
      faIcon: 'plus',
      text: 'New Tile',
      classList: 'new-tile-button js-new-tile-button button icon',
      statusDisplay: ['user_submitted', 'plan', 'draft', 'active', 'archive'],
  }],
};
