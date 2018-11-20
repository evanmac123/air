import React from "react";
import PropTypes from "prop-types";
import { connect } from "react-redux";

import { AiRouter, TileStateManager } from "../lib/utils";
import { Fetcher } from "../lib/helpers";
import { setUserData, setTilesData, setOrganizationData } from "../lib/redux/actions";
import { getSanitizedState } from "../lib/redux/selectors";
import routes from '../config/routes';

class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      currentRoute: '',
      routeData: {},
      originId: null,
      tileOrigin: null,
      tileActions: null,
      appLoading: true,
    };
    this.setUser = this.setUser.bind(this);
    this.setTiles = this.setTiles.bind(this);
    this.openFullSizeTile = this.openFullSizeTile.bind(this);
    this.closeTile = this.closeTile.bind(this);
    this.redirectTo = this.redirectTo.bind(this);
    this.airouter = new AiRouter(routes, this);
  }

  componentDidMount() {
    this.airouter.connect();
    this.setInitialState();
  }

  componentWillUnmount() {
    this.airouter.disconnect();
  }

  setInitialState() {
    Fetcher.xmlHttpRequest({
      method: 'GET',
      path: `/api/v1/initialize`,
      success: resp => {
        this.setUser(resp.user);
        this.setOrganization(resp.organization);
        this.setState({appLoading: false});
      },
      err: () => this.setState({appLoading: false}),
    });
  }

  setUser(data) {
    this.props.setUserData(data);
  }

  setTiles(data) {
    this.props.setTilesData(data);
  }

  setOrganization(data) {
    this.props.setOrganizationData(data);
  }

  redirectTo(path) {
    window.location = path;
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
    const  { userData, tiles, organization, progressBarData, initData } = this.props;
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
        routeData: this.state.routeData,
        setUser: this.setUser,
        setTiles: this.setTiles,
        openFullSizeTile: this.openFullSizeTile,
        redirectTo: this.redirectTo,
        appLoading: this.state.appLoading,
        ctrl: initData,
        user: userData,
        tiles,
        organization,
        progressBarData,
      }) :
      ''
    );
  }
}

App.propTypes = {
  initData: PropTypes.object,
  setUserData: PropTypes.func,
  setTilesData: PropTypes.func,
  setOrganizationData: PropTypes.func,
  userData: PropTypes.object,
  tiles: PropTypes.shape({
    explore: PropTypes.object,
    edit: PropTypes.object,
    complete: PropTypes.object,
    incomplete: PropTypes.object,
  }),
};

export default connect(
  getSanitizedState,
  { setUserData, setTilesData, setOrganizationData }
)(App);
