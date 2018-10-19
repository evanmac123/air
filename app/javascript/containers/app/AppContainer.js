import React from "react";
import PropTypes from "prop-types";
import { connect } from "react-redux";

import { AiRouter, TileStateManager } from "../../lib/utils";
import { setUserData, setTilesData } from "../../lib/redux/actions";
import { getSanitizedState } from "../../lib/redux/selectors";
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
      tileOrigin: null,
    };
    this.setUser = this.setUser.bind(this);
    this.setTiles = this.setTiles.bind(this);
    this.openFullSizeTile = this.openFullSizeTile.bind(this);
    this.closeTile = this.closeTile.bind(this);
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
    this.setState({ fullSizeTile, tileOrigin: opts.from });
  }

  closeTile() {
    this.setState({ fullSizeTile: null, tileOrigin: null });
  }

  render() {
    return React.createElement('div', {className: 'react-root'},
    this.state.fullSizeTile ? React.createElement(TileStateManager, {
      fullSizeTile: this.state.fullSizeTile,
      tileOrigin: this.state.tileOrigin,
      closeTile: this.closeTile,
    }) :
    null,
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

export default connect(
  getSanitizedState,
  { setUserData, setTilesData }
)(App);
