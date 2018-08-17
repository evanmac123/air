import React from 'react';
import PropTypes from "prop-types";

import { DateMaker, MapWithIndex } from "../../../lib/helpers";

const renderMonthOptions = activeStatus => (
  MapWithIndex(activeStatus === 'plan' ? DateMaker.spelledOutMonths.concat('Unplanned') : DateMaker.spelledOutMonths, (month, index) => (
    React.createElement('option', {className: "js-filter-option", value: "<%= index %>", key: index},
      month,
    )
  ))
);

const renderYearOptions = () => (
  // <option data-key="year" className="js-filter-option" value="<%= year %>"><%= year %></option>
  []
);

const TileFilterSubNavComponent = props => (
  <div className="tabs-component-full-width-sub-nav js-tiles-index-filter-bar">
    <div className="row">
      <ul className="sub-nav-options">
        <li className="sub-nav-option">
          <select className="dropdown-button-component transparent js-month-filter-options js-tile-filter-select">
            <option data-key="month" className="js-filter-option" value="all">All months</option>
            { renderMonthOptions(props.activeStatus) }
          </select>
        </li>

        {
          props.activeStatus !== 'plan' &&
          <li className="sub-nav-option">
            <select className="dropdown-button-component transparent js-year-filter-options js-tile-filter-select">
              <option data-key="year" className="js-filter-option" value="all">All years</option>
              { renderYearOptions() }
            </select>
          </li>
        }

        <li className="sub-nav-option">
          <select className="js-tile-filter-select dropdown-button-component transparent campaign-filter-options js-campaign-filter-options">
            <option data-key="campaign" className="js-filter-option" value="all">All campaigns</option>
            <option data-key="campaign" className="js-filter-option" value="unassigned">Unassigned</option>
            <option data-key="campaign" className="js-filter-option" value="<%= campaign.id %>">CAMPAIGN NAMES</option>
            <option data-key="campaign" className="js-create-campaign create-campaign" disabled>+ Create Campaign</option>
          </select>
        </li>

        <li className="sub-nav-option end">
          <select className="js-tile-filter-select dropdown-button-component transparent js-tile-sort">
            <option data-key="sort" className="js-filter-option" value="position">Sort by drag and drop</option>
            <option data-key="sort" className="js-filter-option" value="month">Sort by date</option>
          </select>
        </li>
      </ul>
    </div>
  </div>
);

TileFilterSubNavComponent.propTypes = {
  activeStatus: PropTypes.string.isRequired,
};

export default TileFilterSubNavComponent;
