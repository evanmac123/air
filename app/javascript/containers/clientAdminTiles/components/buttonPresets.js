import React from "react";
import ClientAdminButtonComponent from "./ClientAdminButtonComponent";

const BaseButton = (args, key, action, status, buttonText) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    aClass: 'button update_status',
    aData: {action, status, tileId: args.tile.id},
    onClickAction: (e) => { args.changeTileStatus(args.tile, e) },
    buttonText,
  })
);

const ReadyToSendBtn = (args, key) => BaseButton(args, key, 'draft', 'draft', 'Ready to Send');

const ArchiveBtn = (args, key) => BaseButton(args, key, 'archive', 'archive', 'Archive');

const UnarchiveBtn = (args, key) => BaseButton(args, key, 'unarchive', 'active', 'Post Again');

const BackToPlanBtn = (args, key) => BaseButton(args, key, 'plan', 'plan', 'Back to Plan');

const IncompleteEditBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    liClass: 'incomplete_button',
    aClass: 'button edit red',
    aData: {action: 'edit', status: args.activeStatus, tileId: args.tile.id},
    onClickAction: (e) => { args.changeTileStatus(args.tile, e) },
    buttonText: 'Edit',
  })
);

const DirectDestroyBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    liClass: 'destroy pill right',
    aClass: 'delete_tile',
    aData: {action: 'delete', tileId: args.tile.id},
    onClickAction: (e) => { args.changeTileStatus(args.tile, e) },
    faIcon: 'trash',
  })
);

const AcceptBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    liClass: 'accept_button',
    aClass: 'accept button',
    aData: {action: 'accept', status: 'plan', tileId: args.tile.id},
    onClickAction: (e) => { args.changeTileStatus(args.tile, e) },
    buttonText: 'Accept',
  })
);

const IgnoreBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    liClass: 'ignore_button',
    aClass: 'update_status button outlined',
    aData: {action: 'ignore', status: 'ignored', tileId: args.tile.id},
    onClickAction: (e) => { args.changeTileStatus(args.tile, e) },
    buttonText: 'Ignore',
  })
);

const UndoIgnoreBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    liClass: 'undo_ignore_button',
    aClass: 'update_status button outlined',
    aData: {action: 'unignore', status: 'user_submitted', tileId: args.tile.id},
    onClickAction: (e) => { args.changeTileStatus(args.tile, e) },
    buttonText: 'Undo Ignore',
  })
);

const EditBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    liClass: 'edit_button pill right',
    aClass: 'edit',
    aData: {action: 'edit', status: args.activeStatus, tileId: args.tile.id},
    onClickAction: (e) => { args.changeTileStatus(args.tile, e) },
    faIcon: 'pencil',
  })
);

const ActivateBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    aClass: 'post_title',
    aData: {action: 'active', status: 'active', tileId: args.tile.id},
    onClickAction: (e) => { args.changeTileStatus(args.tile, e) },
    faIcon: 'thumb-tack',
    spanText: 'Post',
  })
);

const CopyBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    aClass: 'duplicate_tile',
    aData: {tileId: args.tile.id},
    onClickAction: (e) => { args.changeTileStatus(args.tile, e) },
    faIcon: 'copy',
    spanText: 'Copy',
  })
);

const DeleteBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    aClass: 'delete_tile',
    aData: {tileId: args.tile.id},
    onClickAction: (e) => { args.changeTileStatus(args.tile, e) },
    faIcon: 'trash-o',
    spanText: 'Delete',
  })
);

const buttonPresets = {
  ReadyToSendBtn,
  IncompleteEditBtn,
  DirectDestroyBtn,
  ArchiveBtn,
  UnarchiveBtn,
  BackToPlanBtn,
  AcceptBtn,
  IgnoreBtn,
  UndoIgnoreBtn,
  EditBtn,
  ActivateBtn,
  CopyBtn,
  DeleteBtn,
};

export default buttonPresets;

export {
  ReadyToSendBtn,
  IncompleteEditBtn,
  DirectDestroyBtn,
  ArchiveBtn,
  UnarchiveBtn,
  BackToPlanBtn,
  AcceptBtn,
  IgnoreBtn,
  UndoIgnoreBtn,
  EditBtn,
  ActivateBtn,
  CopyBtn,
  DeleteBtn,
};
