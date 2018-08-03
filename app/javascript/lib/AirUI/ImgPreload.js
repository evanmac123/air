import React, { Component } from "react";
import PropTypes from "prop-types";

class ImgPreload extends Component {
  constructor(props) {
    super(props);
    this.state = { imageLoading: true };
    this.handleImageState = this.handleImageState.bind(this);
    this.getSource = this.getSource.bind(this);
    this.getStyle = this.getStyle.bind(this);
  }

  componentDidMount() {
    this.setState({
      imageSrc: this.props.loadingSrc || this.props.src,
      imageStyle: this.props.loadingStyle || this.props.style,
    });
  }

  getSource(state) {
    return state === 'load' ? this.props.src || this.props.loadingSrc || this.props.errorSrc : this.props.errorSrc || this.props.loadingSrc || this.props.src;
  }

  getStyle(state) {
    return state === 'load' ? this.props.style || this.props.loadingStyle || this.props.errorStyle : this.props.errorStyle || this.props.loadingStyle || this.props.style;
  }

  handleImageState(state) {
    this.setState({
      imageLoading: false,
      imageSrc: this.getSource(state),
      imageStyle: this.getStyle(state),
    });
  }

  render() {
    return React.createElement("img", {
      src: this.state.imageSrc,
      onLoad: () => this.handleImageState('load'),
      onError: () => this.handleImageState('error'),
      style: this.state.imageStyle,
    });
  }
}

ImgPreload.propTypes = {
  loadingSrc: PropTypes.string,
  errorSrc: PropTypes.string,
  src: PropTypes.string,
  loadingStyle: PropTypes.object,
  errorStyle: PropTypes.object,
  style: PropTypes.object,
};

export default ImgPreload;
