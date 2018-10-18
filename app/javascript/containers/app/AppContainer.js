import React from "react";
import PropTypes from "prop-types";
import { connect } from "react-redux";

import { AiRouter, TileStateManager } from "../../lib/utils";
import { setUserData, setTilesData } from "../../lib/redux/actions";
import Explore from "../explore/ExploreContainer";
import ClientAdminTiles from "../clientAdminTiles/ClientAdminTilesContainer";

const routes = {
  '/explore': Explore,
  '/explore/campaigns/:campaign': Explore,
  '/client_admin/tiles': ClientAdminTiles,
};

class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      currentRoute: '',
      routeData: {},
      fullSizeTile: null,
    };
    this.setUser = this.setUser.bind(this);
    this.setTiles = this.setTiles.bind(this);
    this.openFullSizeTile = this.openFullSizeTile.bind(this);
    this.airouter = new AiRouter(routes, this);
  }

  componentDidMount() {
    this.airouter.connect();
  }

  componentWillUnmount() {
    this.airouter.disconnect();
  }

  setUser(data) {
    this.props.setUserData(data);
  }

  setTiles(data) {
    this.props.setTilesData(data);
  }

  openFullSizeTile(opts) {
    const fullSizeTile = this.props.tiles[opts.from][opts.id];
    // console.log(fullSizeTile);
  }

  render() {
    return React.createElement('div', {className: 'react-root'},
    React.createElement(TileStateManager, {fullSizeTile: this.state.fullSizeTile}),
    this.state.currentRoute && !this.state.fullSizeTile ?
      React.createElement(routes[this.state.currentRoute], {
        ctrl: this.props.initData,
        routeData: this.state.routeData,
        setUser: this.setUser,
        setTiles: this.setTiles,
        openFullSizeTile: this.openFullSizeTile,
      }) :
      ''
    );
  }
}

App.propTypes = {
  initData: PropTypes.object,
};

const mapStateToProps = state => {
  return { userData: state.userData, tiles: state.tilesData };
};

export default connect(
  mapStateToProps,
  { setUserData, setTilesData }
)(App);
