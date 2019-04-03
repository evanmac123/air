import React from "react";
import PropTypes from "prop-types";

import Autocomplete from '../../lib/utils/autocomplete';
import { Fetcher } from '../../lib/helpers';
import LoadingComponent from '../../shared/LoadingComponent';
import ProgressBarComponent from '../../shared/ProgressBarComponent';
import TileWallComponent from './components/TileWallComponent';
// import ActsFeedComponent from './components/ActsFeedComponent';
import ConnectionsComponent from './components/ConnectionsComponent';
import InviteUsersComponent from './components/InviteUsersComponent';
import PotentialUserModal from './components/PotentialUserModal';

const toggleButtonLoadingSpinner = el => {
  /* eslint-disable no-param-reassign */
  el.style.pointerEvents = el.style.pointerEvents === 'none' ? '' : 'none';
  for (let i = 0; i < el.children.length; i++) {
    el.children[i].style.display = el.children[i].style.display === 'none' ? '' : 'none';
  }
  /* eslint-enable */
};

class ActivityBoard extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      loading: true,
      connections: null,
      potentialUserModal: null,
    };
    this.openTileModal = this.openTileModal.bind(this);
    this.loadMoreTiles = this.loadMoreTiles.bind(this);
  }

  componentDidMount() {
    this.props.loadTiles({
      loadAll: true,
      perPage: 16,
      success: resp => {
        this.props.setTiles(resp.tiles);
        this.setState({loading: false});
      },
      error: resp => {
        console.error("Something went wrong fetching tiles from DB", resp);
        this.setState({loading: false});
      },
    });
    if (this.props.demo && !this.props.demo.hideSocial && !this.props.user.isGuestUser) {
      this.loadUserConnections();
    }
    this.launchWelcomeModals();
  }

  loadMoreTiles() {
    toggleButtonLoadingSpinner(document.getElementsByClassName("show_more_tiles")[0]);
    this.props.loadTiles({
      perPage: 16,
      success: resp => {
        this.props.addTiles(resp.tiles);
        toggleButtonLoadingSpinner(document.getElementsByClassName("show_more_tiles")[0]);
      },
      error: resp => {
        console.error("Something went wrong fetching additional tiles from the DB", resp);
        toggleButtonLoadingSpinner(document.getElementsByClassName("show_more_tiles")[0]);
      },
    });
  }

  openTileModal(id) {
    const {demo, user} = this.props;
    const baseRoute = demo.isPublic && user.isGuestUser ? `/ard/${demo.publicSlug}/tiles` : '/tiles';
    this.props.navigateTo(`${baseRoute}?tile_id=${id}`);
  }

  loadUserConnections() {
    Fetcher.xmlHttpRequest({
      method: 'GET',
      path: `/api/v1/friendships`,
      success: connections => this.setState({ connections }),
    });
  }

  autocomplete() {
    // Legacy functions triggering autocomplete legacy code (import '../../lib/utils/autocomplete';)
    /* eslint-disable */
    Autocomplete.startWatchDog();
    Autocomplete.markForSend();
    /* eslint-enable */
  }

  launchWelcomeModals() {
    window.Airbo.BoardWelcomeModal.init();
    if (this.props.user.displayBoardWelcomeMessage) {
      window.Airbo.BoardWelcomeModal.open();
    }
    if (this.props.user.isPotentialUser) {
      this.openPotentialUserModal();
    }
  }

  openPotentialUserModal() {
    const potentialUserModal = React.createElement(PotentialUserModal, {
      onClose: () => this.setState({potentialUserModal: null}),
      demoName: this.props.demo.name,
      setUser: this.props.setUser,
    });
    this.setState({ potentialUserModal });
  }

  render() {
    return (
      <div className="content">
        <div className="user_container"><ProgressBarComponent /></div>

        <div id="tile_wall" style={this.state.loading ? {paddingBottom: '250px'} : {}}>
          {this.state.loading ?
            <LoadingComponent /> :
            <TileWallComponent
              tiles={this.props.tiles}
              openTileModal={this.openTileModal}
              loadMoreTiles={this.loadMoreTiles}
              allTilesDisplayed={this.props.tiles.paginateState.allTilesDisplayed}
            />
          }
        </div>

        <div className="row">
          <div className="large-4 columns">
          </div>

          {(this.props.demo && !this.props.demo.hideSocial && !this.props.user.isGuestUser) &&
            <span>
              <div className="large-4 columns">
                <div className="module">
                <h3 className="feeds_title">Activity</h3>
                  <p style={{lineHeight: '2.6em'}}>
                    <span style={{fontSize: '17px'}}>Looking for your Activity feed?</span><br />We’ve temporarily moved it to your <a href={this.props.user.path}>profile</a>.
                  </p>
                </div>
              </div>
              <div className="large-4 columns">
                <ConnectionsComponent {...this.props} connections={this.state.connections} />
              </div>

              <div className="large-4 columns">
                <InviteUsersComponent {...this.props} autocomplete={this.autocomplete} />
              </div>
            </span>
          }
        </div>
        { this.state.potentialUserModal }
      </div>
    );
  }
}

ActivityBoard.propTypes = {
  loadTiles: PropTypes.func,
  setTiles: PropTypes.func,
  setTilesPaginationState: PropTypes.func,
  addTiles: PropTypes.func,
  setUser: PropTypes.func,
  navigateTo: PropTypes.func,
  tiles: PropTypes.shape({
    complete: PropTypes.object,
    incomplete: PropTypes.object,
    paginateState: PropTypes.object,
  }),
  demo: PropTypes.object,
  user: PropTypes.object,
};

export default ActivityBoard;
