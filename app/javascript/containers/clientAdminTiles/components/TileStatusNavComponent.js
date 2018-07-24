import React from "react";

const renderTabs = props => (
  props.statuses.map(statusNav => (
    React.createElement("li",
      {
        className: `tab `,
        onClick: props.selectStatus,
        key: statusNav.status,
        style: {color: `${statusNav.status === props.activeStatus ? "#48bfff" : "#8da0ab"}`},
      },
      `${statusNav.status} `,
      React.createElement("span",
        {className: "x-small"},
        `(${statusNav.tileCount})`
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
        renderTabs(props)
      )
    )
  )
);

export default TileStatusNavComponent;
