import React from "react";
import PropTypes from "prop-types";

import { constants } from "../utils";

const maxCount = count => count > 500 ? '500+' : count;

const renderTabs = props => (
  Object.keys(props.statuses).map(statusNav => (
    React.createElement("li",
      {
        className: 'tab',
        onClick: () => { props.selectStatus(statusNav); },
        key: statusNav,
        style: {color: `${statusNav === props.activeStatus ? "#48bfff" : "#8da0ab"}`},
      },
      `${props.statuses[statusNav].uiDisplay} `,
      React.createElement("span",
        {className: "x-small"},
        `(${statusNav === 'share' ? maxCount(props.tiles.draft.count) : maxCount(props.tiles[statusNav].count)})`
      )
    )
  ))
);

const renderButtons = activeStatus => constants.NAV_BUTTONS.map((btn, key) => (
  btn.statusDisplay.indexOf(activeStatus) > -1 ?
    React.createElement('a',
      {className: btn.classList, key, href: btn.faIcon === 'download' ? `/client_admin/tiles_report.csv?report=${activeStatus}` : ''},
      React.createElement('span', {className: `fa fa-${btn.faIcon}`}),
      btn.text,
    ) :
    null
));

const TileStatusNavComponent = props => (
  React.createElement("div",
    {className: "tabs-component-full-width no-bottom-border"},
    React.createElement("div",
      {className: "row"},
      React.createElement("ul",
        {className: "with-tiles"},
        renderTabs(props),
        React.createElement("li",
          {className: 'buttons'},
          renderButtons(props.activeStatus),
          React.createElement("span",
            {
              className: "button outlined icon",
              onClick: props.openCampaignManager,
            },
            React.createElement('span', {className: `fa fa-gear`}),
            "Board Settings",
          )
        )
      )
    )
  )
);

TileStatusNavComponent.propTypes = {
  activeStatus: PropTypes.string.isRequired,
  openCampaignManager: PropTypes.func.isRequired,
};

export default TileStatusNavComponent;
