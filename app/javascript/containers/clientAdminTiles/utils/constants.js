const baseAlertOptions = {
  customClass: 'airbo',
  cancelBtnCssClass: 'cancel',
  confirmBtnCssClass: 'confirm',
  showCancel: true,
  style: {
    display: 'inherit',
    width: '520px',
  },
};

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
    },
    deleteConfirm: {
      method: 'DELETE',
      url: 'destroy_tile',
    },
  },
  UNASSIGNED_CAMPAIGN: {label: 'Unassigned', className: 'campaign-option', value: '0', color: '#fff'},
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
  POST_AGAIN_MODAL_TEXT: {
    ...baseAlertOptions,
    title: 'Are you sure about that?',
    confirmBtnText: 'Post Again',
    text: 'Users who have completed this Tile already will not see it again. If you want to re-use the content, it may be better to create a copy.',
  },
  post_MENU_ALERT_TEXT: {
    ...baseAlertOptions,
    title: 'Are you sure about that?',
    text: 'Tiles are posted automatically when they are delivered. If you manually post a Tile, it will not appear in your next Tile Digest.',
  },
  delete_MENU_ALERT_TEXT: {
    ...baseAlertOptions,
    title: 'Deleting a tile cannot be undone',
    text: 'Are you sure you want to delete this tile?',
  },
};
