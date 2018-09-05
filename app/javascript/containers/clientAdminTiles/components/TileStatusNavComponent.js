import React from "react";
import PropTypes from "prop-types";

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

const renderButtons = (activeStatus, navButtons) => (
  navButtons.map((btn, key) => (
    btn.statusDisplay.indexOf(activeStatus) > -1 ?
      React.createElement('a',
        {className: btn.classList, key},
        React.createElement('span', {className: `fa fa-${btn.faIcon}`}),
        btn.text,
      ) :
      null
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
        React.createElement("li",
          {className: 'buttons'},
          renderButtons(props.activeStatus, props.navButtons),
        )
      )
    )
  )
);

TileStatusNavComponent.propTypes = {
  activeStatus: PropTypes.string.isRequired,
  navButtons: PropTypes.arrayOf(PropTypes.shape({
    faIcon: PropTypes.string.isRequired,
    text: PropTypes.string.isRequired,
    classList: PropTypes.string.isRequired,
    tooltip: PropTypes.string,
    statusDisplay: PropTypes.arrayOf(PropTypes.string).isRequired,
  })).isRequired,
};

export default TileStatusNavComponent;
