import React from "react";
import PropTypes from "prop-types";

import '../../lib/utils/autocomplete';
import { Fetcher } from '../../lib/helpers';
import LoadingComponent from '../../shared/LoadingComponent';
import ProgressBarComponent from '../../shared/ProgressBarComponent';
import TileWallComponent from './components/TileWallComponent';
// import ActsFeedComponent from './components/ActsFeedComponent';
import ConnectionsComponent from './components/ConnectionsComponent';
import InviteUsersComponent from './components/InviteUsersComponent';

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
      completeTilesPage: 0,
      completeTilesOffset: 0,
      incompleteTilesPage: 1,
      allTilesDisplayed: true,
      connections: null,
    };
    this.loadTiles = this.loadTiles.bind(this);
    this.openTileModal = this.openTileModal.bind(this);
    this.loadMoreTiles = this.loadMoreTiles.bind(this);
  }

  componentDidMount() {
    this.loadTiles({
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
  }

  loadTiles(opts) {
    const {completeTilesPage, incompleteTilesPage, completeTilesOffset} = this.state;
    const {isGuestUser, id} = this.props.user;
    const params = `user_id=${id}&is_guest_user=${isGuestUser}&maximum_tiles=${opts.perPage || '16'}&complete_tiles_page=${completeTilesPage}&incomplete_tiles_page=${incompleteTilesPage}&offset=${completeTilesOffset}`;
    Fetcher.xmlHttpRequest({
      method: 'GET',
      path: `/api/v1/tiles?${params}`,
      success: resp => {
        const {completeTilesPage, incompleteTilesPage, completeTilesOffset, allTilesDisplayed} = resp;
        this.setState({ completeTilesPage, incompleteTilesPage, completeTilesOffset, allTilesDisplayed });
        opts.success(resp);
      },
      err: resp => opts.error(resp),
    });
  }

  loadMoreTiles() {
    toggleButtonLoadingSpinner(document.getElementsByClassName("show_more_tiles")[0]);
    this.loadTiles({
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
    this.props.navigateTo(`/tiles?tile_id=${id}`);
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
    startWatchDog({ calling_div: "#search_for_friends_to_invite" });
    markForSend();
    /* eslint-enable */
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
              allTilesDisplayed={this.state.allTilesDisplayed}
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
      </div>
    );
  }
}

ActivityBoard.propTypes = {
  setTiles: PropTypes.func,
  addTiles: PropTypes.func,
  navigateTo: PropTypes.func,
  tiles: PropTypes.shape({
    complete: PropTypes.object,
    incomplete: PropTypes.object,
  }),
  demo: PropTypes.object,
  user: PropTypes.object,
};

export default ActivityBoard;
