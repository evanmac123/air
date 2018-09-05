import React from "react";
import ClientAdminButtonComponent from "./ClientAdminButtonComponent";

const BaseButton = (args, key, action, status, buttonText) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    aClass: 'button update_status',
    aData: {action, status, tileId: args.tile.id},
    buttonText,
  })
);

const ReadyToSendBtn = (args, key) => BaseButton(args, key, 'draft', 'draft', 'Move to Proof');

const ArchiveBtn = (args, key) => BaseButton(args, key, 'archive', 'archive', 'Archive');

const UnarchiveBtn = (args, key) => BaseButton(args, key, 'unarchive', 'active', 'Post Again');

const BackToPlanBtn = (args, key) => BaseButton(args, key, 'plan', 'plan', 'Back to Plan');

const IncompleteEditBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    liClass: 'incomplete_button',
    aClass: 'button edit red',
    aData: {action: 'edit', status: args.activeStatus, tileId: args.tile.id},
    buttonText: 'Edit',
  })
);

const DirectDestroyBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    liClass: 'destroy pill right',
    aClass: 'delete_tile',
    aData: {action: 'delete', tileId: args.tile.id},
    faIcon: 'trash',
  })
);

const AcceptBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    liClass: 'accept_button',
    aClass: 'accept button',
    aData: {action: 'accept', status: 'plan', tileId: args.tile.id},
    buttonText: 'Accept',
  })
);

const IgnoreBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    liClass: 'ignore_button',
    aClass: 'update_status button outlined',
    aData: {action: 'ignore', status: 'ignored', tileId: args.tile.id},
    buttonText: 'Ignore',
  })
);

const UndoIgnoreBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    liClass: 'undo_ignore_button',
    aClass: 'update_status button outlined',
    aData: {action: 'unignore', status: 'user_submitted', tileId: args.tile.id},
    buttonText: 'Undo Ignore',
  })
);

const EditBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    liClass: 'edit_button pill right',
    aClass: 'edit',
    aData: {action: 'edit', status: args.activeStatus, tileId: args.tile.id},
    faIcon: 'pencil',
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
};
