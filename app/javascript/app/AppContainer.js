import React from "react";
import PropTypes from "prop-types";
import SweetAlert from 'react-bootstrap-sweetalert';
import { connect } from "react-redux";

import { AiRouter, TileStateManager } from "../lib/utils";
import { Fetcher } from "../lib/helpers";
import { setUserData, setTilesData, setOrganizationData, setDemoData, addTilesToStore } from "../lib/redux/actions";
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
    this.addTiles = this.addTiles.bind(this);
    this.openFullSizeTile = this.openFullSizeTile.bind(this);
    this.closeTile = this.closeTile.bind(this);
    this.redirectTo = this.redirectTo.bind(this);
    this.navigateTo = this.navigateTo.bind(this);
    this.airouter = new AiRouter(routes, this);
  }

  componentDidMount() {
    this.airouter.connect();
    this.setInitialState();
  }

  componentDidUpdate() {
  }

  componentWillUnmount() {
    this.airouter.disconnect();
  }

  setInitialState() {
    const {loadedBoard, currentBoard, currentUser, isGuestUser} = this.props.initData;
    const params = loadedBoard ? `demo_id=${currentBoard}&user_id=${currentUser}&is_guest_user=${isGuestUser}` : '';
    Fetcher.xmlHttpRequest({
      method: 'GET',
      path: `/api/v1/initialize?${params}`,
      success: resp => {
        this.setUser(resp.user);
        this.setOrganization(resp.organization);
        this.setDemo(resp.demo);
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

  setDemo(data) {
    this.props.setDemoData(data);
  }

  addTiles(data) {
    this.props.addTilesToStore(data);
  }

  redirectTo(path) {
    window.location = path;
  }

  navigateTo(path, opts) {
    this.airouter.navigation(path);
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
    const  { userData, tiles, organization, demo, progressBarData, initData } = this.props;
    return React.createElement('div', {className: 'react-root'},
    this.state.originId ? React.createElement(TileStateManager, {
      originId: this.state.originId,
      tileOrigin: this.state.tileOrigin,
      tileActions: this.state.tileActions,
      closeTile: this.closeTile,
      navigateTo: this.navigateTo,
      userData,
    }) :
    null,
    this.state.currentRoute && !this.state.originId && !this.state.appLoading ?
      React.createElement(routes[this.state.currentRoute], {
        routeData: this.state.routeData,
        setUser: this.setUser,
        setTiles: this.setTiles,
        addTiles: this.addTiles,
        openFullSizeTile: this.openFullSizeTile,
        redirectTo: this.redirectTo,
        navigateTo: this.navigateTo,
        appLoading: this.state.appLoading,
        ctrl: initData,
        user: userData,
        tiles,
        demo,
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
  addTilesToStore: PropTypes.func,
  setOrganizationData: PropTypes.func,
  setDemoData: PropTypes.func,
  userData: PropTypes.object,
  organization: PropTypes.object,
  demo: PropTypes.object,
  progressBarData: PropTypes.object,
  tiles: PropTypes.shape({
    explore: PropTypes.object,
    edit: PropTypes.object,
    complete: PropTypes.object,
    incomplete: PropTypes.object,
  }),
};

export default connect(
  getSanitizedState,
  { setUserData, setTilesData, setOrganizationData, setDemoData, addTilesToStore }
)(App);
