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

export const ReadyToSendBtn = (args, key) => BaseButton(args, key, 'draft', 'draft', 'Move to Proof');

export const ArchiveBtn = (args, key) => BaseButton(args, key, 'archive', 'archive', 'Archive');

export const UnarchiveBtn = (args, key) => BaseButton(args, key, 'unarchive', 'active', 'Post Again');

export const BackToPlanBtn = (args, key) => BaseButton(args, key, 'plan', 'plan', 'Back to Plan');

export const IncompleteEditBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    liClass: 'incomplete_button',
    aClass: 'button edit red',
    aData: {action: 'edit', status: args.activeStatus, tileId: args.tile.id},
    buttonText: 'Edit',
  })
);

export const DirectDestroyBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    liClass: 'destroy pill right',
    aClass: 'delete_tile',
    aData: {action: 'delete', tileId: args.tile.id},
    faIcon: 'trash',
  })
);

export const AcceptBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    liClass: 'accept_button',
    aClass: 'update_status accept button',
    aData: {action: 'accept', status: 'plan', tileId: args.tile.id},
    buttonText: 'Accept',
  })
);

export const IgnoreBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    liClass: 'ignore_button',
    aClass: 'update_status ignore button outlined',
    aData: {action: 'ignore', status: 'ignored', tileId: args.tile.id},
    buttonText: 'Ignore',
  })
);

export const UndoIgnoreBtn = (args, key) => (
  React.createElement(ClientAdminButtonComponent, {
    key,
    liClass: 'undo_ignore_button',
    aClass: 'update_status undo_ignore button outlined',
    aData: {action: 'unignore', status: 'user_submitted', tileId: args.tile.id},
    buttonText: 'Undo Ignore',
  })
);

export const EditBtn = (args, key) => (
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
