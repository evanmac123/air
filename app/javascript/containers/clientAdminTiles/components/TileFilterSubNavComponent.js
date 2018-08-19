import React from 'react';
import PropTypes from "prop-types";
import Select from 'react-select';

import { DateMaker, MapWithIndex } from "../../../lib/helpers";

const renderMonthOptions = activeStatus => {
  const result = [];
  if (activeStatus === 'plan') { result.push({value: 0, label: 'Unplanned'}); }
  return result.concat(MapWithIndex(DateMaker.spelledOutMonths, (label, index) => (
    {label, className: 'date-option', value: (index + 1)}
  )));
};

const renderYearOptions = () => {
  const date = new Date();
  const years = [];
  for (let year = 2014; year <= date.getFullYear(); year++) { years.push(year); }
  return years.reverse().map(label => (
    {label, className: 'year-option', value: label}
  ));
};

const renderCampaignOptions = () => {
  const result = [{label: 'Unassigned', className: 'campaign-option', value: 'unassigned'}];
  // logic for rendering campaigns
  result.push({label: '+ Create Campaign', className: 'campaign-option', value: 'create_campaign'});
  return result;
};

const renderSortOptions = () => ([
  {label: 'Sort by Drag & Drop', className: 'sort-option', value: 'dnd'},
  {label: 'Sort by Date', className: 'sort-option', value: 'date-sort'},
]);

const TileFilterSubNavComponent = props => (
  <div className="tabs-component-full-width-sub-nav js-tiles-index-filter-bar">
    <div className="row">
      <ul className="sub-nav-options">
        <li className="sub-nav-option" style={{width: '15%'}}>
          <Select
            className="react-select date-filter"
            placeholder="All Months"
            isClearable={true}
            options={renderMonthOptions(props.activeStatus)}
            isSearchable={false}
          />
        </li>

        {
          props.activeStatus !== 'plan' &&
          <li className="sub-nav-option" style={{width: '12%'}}>
            <Select
              className="react-select date-filter"
              placeholder="All Years"
              isClearable={true}
              options={renderYearOptions()}
              isSearchable={false}
            />
          </li>
        }

        <li className="sub-nav-option" style={{width: '15%'}}>
          <Select
            className="react-select date-filter"
            placeholder="All Campaigns"
            isClearable={true}
            options={renderCampaignOptions()}
            isSearchable={true}
          />
        </li>

        <li className="sub-nav-option end" style={{width: '20%'}}>
          <Select
            className="react-select date-filter"
            placeholder="Sort..."
            isClearable={true}
            options={renderSortOptions()}
            isSearchable={false}
          />
        </li>
      </ul>
    </div>
  </div>
);

TileFilterSubNavComponent.propTypes = {
  activeStatus: PropTypes.string.isRequired,
};

export default TileFilterSubNavComponent;
