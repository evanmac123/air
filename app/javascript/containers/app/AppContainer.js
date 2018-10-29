import React from "react";
import PropTypes from "prop-types";
import { connect } from "react-redux";

import { AiRouter, TileStateManager } from "../../lib/utils";
import { setUserData, setTilesData } from "../../lib/redux/actions";
import { getSanitizedState } from "../../lib/redux/selectors";
import Explore from "../explore/ExploreContainer";
import ClientAdminTiles from "../clientAdminTiles/ClientAdminTilesContainer";
import TileCarousel from "../tileCarousel/TileCarouselContainer";

const routes = {
  '/explore': Explore,
  '/explore/campaigns/:campaign': Explore,
  '/client_admin/tiles': ClientAdminTiles,
  '/tiles': TileCarousel,
};

class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      currentRoute: '',
      routeData: {},
      originId: null,
      tileOrigin: null,
      tileActions: null,
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
    this.setState({
      originId: opts.id,
      tileOrigin: opts.from,
      tileActions: opts.tileActions,
    });
  }

  closeTile() {
    this.setState({ originId: null, tileOrigin: null, tileActions: null });
  }

  render() {
    return React.createElement('div', {className: 'react-root'},
    this.state.originId ? React.createElement(TileStateManager, {
      originId: this.state.originId,
      tileOrigin: this.state.tileOrigin,
      tileActions: this.state.tileActions,
      closeTile: this.closeTile,
      userData: this.props.userData,
    }) :
    null,
    this.state.currentRoute && !this.state.originId ?
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
  setUserData: PropTypes.func,
  setTilesData: PropTypes.func,
};

export default connect(
  getSanitizedState,
  { setUserData, setTilesData }
)(App);
