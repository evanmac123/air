import React from "react";
import PropTypes from "prop-types";

import ManagerMainComponent from "./components/ManagerMainComponent";
import RibbonTagFormComponent from "./components/RibbonTagFormComponent";
import constants from "./utils/constants";
import { Fetcher } from "../../lib/helpers";

const getIndexOfRibbonTag = (id, ribbonTags) => {
  for (let index = 0; index < ribbonTags.length; index++) { if (ribbonTags[index].value === id) { return index; } }
  return false;
};

const sanitizeRibbonTagResponse = tag => (
  {label: tag.name, className: 'ribbon-tag-option', value: tag.id, color: tag.color, population: tag.population_segment_id}
);

class RibbonTagManagerComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      name: '',
      color: '#93f7dd',
      editRibbonTagId: '',
      loading: true,
      errorStyling: {},
      ribbonTags: [],
      activeComponent: '',
      errorMsg: '',
      errorId: '',
      ribbonTagsOpen: false,
    };
    this.handleFormState = this.handleFormState.bind(this);
    this.submitRibbonTag = this.submitRibbonTag.bind(this);
    this.applyErrors = this.applyErrors.bind(this);
    this.setColorSelection = this.setColorSelection.bind(this);
    this.updateRibbonTagState = this.updateRibbonTagState.bind(this);
    this.deleteRibbonTag = this.deleteRibbonTag.bind(this);
    this.editRibbonTag = this.editRibbonTag.bind(this);
    this.newRibbonTag = this.newRibbonTag.bind(this);
    this.removeRibbonTagFromState = this.removeRibbonTagFromState.bind(this);
    this.compareChanges = this.compareChanges.bind(this);
    this.ribbonTagAbleToSave = this.ribbonTagAbleToSave.bind(this);
    this.getFetcherOpts = this.getFetcherOpts.bind(this);
    this.toggleNewRibbonTagForm = this.toggleNewRibbonTagForm.bind(this);
    this.toggleRibbonTagList = this.toggleRibbonTagList.bind(this);
    this.resetForm = this.resetForm.bind(this);
  }

  componentDidMount() {
    const ribbonTags = [...this.props.ribbonTags];
    ribbonTags.shift();
    this.setState({ loading: false, ribbonTags });
  }

  componentDidUpdate() {
    const {ribbonTags} = this.state;
    this.props.onUpdate({ ribbonTags });
  }

  resetForm() {
    this.setState({
      name: '',
      color: '#93f7dd',
      editRibbonTagId: '',
      activeComponent: '',
    });
  }

  toggleNewRibbonTagForm() {
    const { activeComponent } = this.state;
    this.resetForm();
    this.setState({activeComponent: activeComponent === 'newRibbonTag' ? '' : 'newRibbonTag'});
  }

  toggleRibbonTagList() {
    const { ribbonTagsOpen } = this.state;
    this.setState({ ribbonTagsOpen: !ribbonTagsOpen });
  }

  ribbonTagAbleToSave() {
    return (this.state.name && this.state.color && !this.state.loading && this.compareChanges());
  }

  getFetcherOpts() {
    return {
      params: {
        name: this.state.name,
        color: this.state.color,
      },
      path: `${constants.BASE_URL}${this.state.editRibbonTagId ? this.state.editRibbonTagId : ''}`,
      method: this.state.editRibbonTagId ? 'PUT' : 'POST',
    };
  }

  applyErrors() {
    const errorStyling = {};
    if (!this.state.name) { errorStyling.name = {borderColor: 'red'}; }
    this.setState({ errorStyling });
  }

  handleFormState(field, val) {
    const newState = {};
    newState[field] = val;
    if (this.state.errorStyling[field]) {
      newState.errorStyling = {...this.state.errorStyling};
      newState.errorStyling[field] = null;
    }
    this.setState(newState);
  }

  removeRibbonTagFromState(tagResp) {
    const ribbonTags = [...this.state.ribbonTags];
    ribbonTags.splice(getIndexOfRibbonTag(tagResp.ribbon_tag.id, ribbonTags), 1);
    this.setState({ ribbonTags });
  }

  updateRibbonTagState(resp) {
    const ribbonTags = [...this.state.ribbonTags];
    const newRibbonTag = sanitizeRibbonTagResponse(resp.ribbon_tag);
    if (this.state.editRibbonTagId) {
      const index = getIndexOfRibbonTag(resp.ribbon_tag.id, ribbonTags);
      ribbonTags.splice(index, 1);
      ribbonTags.splice(index, 0, newRibbonTag);
    } else {
      ribbonTags.push(newRibbonTag);
    }
    this.setState({...constants.DEFAULT_STATE, ribbonTags});
  }

  submitRibbonTag() {
    if (this.ribbonTagAbleToSave()) {
      const {params, path, method} = this.getFetcherOpts();
      this.setState({loading: true});
      Fetcher.xmlHttpRequest({
        method,
        path,
        params,
        success: this.updateRibbonTagState,
        err: () => {
          this.setState({...constants.DEFAULT_STATE, errorMsg: 'Topic could not be created'});
        },
      });
    } else if (!this.compareChanges()) {
      this.setState({...constants.DEFAULT_STATE, errorMsg: 'No changes made to topic'});
    } else {
      this.applyErrors();
    }
  }

  deleteRibbonTag(campId) {
    this.setState({errorMsg: ''});
    Fetcher.xmlHttpRequest({
      method: 'DELETE',
      path: `${constants.BASE_URL}${campId}`,
      success: this.removeRibbonTagFromState,
      err: () => { this.setState({errorMsg: "Cannot delete topic while it's active", errorId: campId}); },
    });
  }

  newRibbonTag() {
    this.setState({
      ...constants.DEFAULT_STATE,
      activeComponent: 'RibbonTagFormComponent',
      color: '#93f7dd',
      errorMsg: '',
    });
  }

  editRibbonTag(campaign) {
    if (this.state.activeComponent !== campaign.value) {
      this.setState({
        activeComponent: campaign.value,
        name: campaign.label,
        editRibbonTagId: campaign.value,
        color: campaign.color,
        errorStyling: {},
        errorMsg: '',
      });
    } else {
      this.resetForm();
    }
  }

  setColorSelection(colorChange) {
    this.setState(colorChange);
  }

  compareChanges() {
    if (!this.state.editRibbonTagId) { return true; }
    const existingRibbonTag = this.state.ribbonTags[getIndexOfRibbonTag(this.state.editRibbonTagId, this.state.ribbonTags)];
    return (
      this.state.name !== existingRibbonTag.label ||
      this.state.color !== existingRibbonTag.color
    );
  }

  render() {
    return React.createElement('div', {className: "manage-campaign-card-container", style: {marginTop: '30px'}},
      (
        <div style={{minHeight: '35px', padding: '0 10px', marginBottom: '15px'}}>
          <span className="campaign-manager-header" style={{float: 'left', fontSize: '24px'}}>Topics</span>
          <div className="campaign-manager-btns" style={{float: 'right'}}>
            <span className="button icon" style={{marginRight: '7px'}}
              onClick={this.toggleNewRibbonTagForm}
            >
              <span
                className={`fa fa-plus ${this.state.activeComponent === 'newRibbonTag' ? 'rotate-close' : ''}`}
                style={{fontSize: '1em', margin: '0'}}
              />
            </span>
            <span className="button outlined icon" onClick={this.toggleRibbonTagList}>
              {this.state.ribbonTagsOpen ? 'Close' : 'Edit'}
            </span>
          </div>
        </div>
      ),
      React.createElement(RibbonTagFormComponent, {
        ...this.state,
        submitRibbonTag: this.submitRibbonTag,
        closeForm: this.toggleNewRibbonTagForm,
        setColorSelection: this.setColorSelection,
        handleFormState: this.handleFormState,
        expanded: this.state.activeComponent === 'newRibbonTag',
      }),
      React.createElement(ManagerMainComponent, {
        ...this.state,
        setColorSelection: this.setColorSelection,
        handleFormState: this.handleFormState,
        deleteRibbonTag: this.deleteRibbonTag,
        editRibbonTag: this.editRibbonTag,
        expanded: this.state.ribbonTagsOpen,
        closeForm: this.resetForm,
        submitRibbonTag: this.submitRibbonTag,
      })
    );
  }
}

RibbonTagManagerComponent.propTypes = {
  ribbonTags: PropTypes.array,
  onUpdate: PropTypes.func.isRequired,
};

export default RibbonTagManagerComponent;
