import React from "react";

const renderTabs = props => (
  Object.keys(props.statuses).map(statusNav => (
    React.createElement("li",
      {
        className: `tab `,
        onClick: () => { props.selectStatus(statusNav); },
        key: statusNav,
        style: {color: `${statusNav === props.activeStatus ? "#48bfff" : "#8da0ab"}`},
      },
      `${props.statuses[statusNav].uiDisplay} `,
      React.createElement("span",
        {className: "x-small"},
        `(${props.tiles[statusNav] ? props.tiles[statusNav].length : 0})`
      )
    )
  ))
);

const TileStatusNavComponent = props => (
  React.createElement("div",
    {className: "tabs-component-full-width no-bottom-border"},
    React.createElement("div",
      {className: "row"},
      React.createElement("ul",
        {className: "with-tiles"},
        renderTabs(props),
      )
    )
  )
);
// <li class="buttons">
//   <%= link_to "#download_stats", class: "hidden download-stats-button js-download-stats-button button outlined icon", title: "Download Excel file with statistics for all of the Tiles in this section.", data: { tooltip: true } do %>
//   <%= fa_icon "download" %>
//   <span>Download Stats</span>
//   <% end %>
//
//   <%= link_to "#suggestion_box_manage_access", class: "js-suggestion-box-manage-access button outlined icon hidden" do %>
//   <%= fa_icon "users" %>
//   <span>Manage Access</span>
//   <% end %>
//
//   <%= link_to new_client_admin_tile_path, class: "new-tile-button js-new-tile-button button icon" do %>
//     <%= fa_icon "plus" %>
//     <span>New Tile</span>
//   <% end %>
// </li>


export default TileStatusNavComponent;
