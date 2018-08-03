import React, { Component } from "react";
import PropTypes from "prop-types";

class ImgPreload extends Component {
  constructor(props) {
    super(props);
    this.state = { imageLoading: true };
    this.handleImageLoaded = this.handleImageLoaded.bind(this);
    this.handleImageError = this.handleImageError.bind(this);
  }

  componentDidMount() {
    this.setState({
      imageSrc: this.props.loadingSrc || this.props.src,
      imageStyle: this.props.loadingStyle || this.props.style,
    });
  }

  handleImageLoaded() {
    this.setState({ imageLoading: false });
    this.setState({
      imageSrc: this.props.src || this.props.loadingSrc || this.props.errorSrc,
      imageStyle: this.props.style || this.props.loadingStyle || this.props.errorStyle,
    });
  }

  handleImageError() {
    this.setState({ imageLoading: false });
    this.setState({
      imageSrc: this.props.errorSrc || this.props.loadingSrc || this.props.src,
      imageStyle: this.props.errorStyle || this.props.loadingStyle || this.props.style,
    });
  }

  render() {
    return React.createElement("img", {
      src: this.state.imageSrc,
      onLoad: this.handleImageLoaded,
      onError: this.handleImageError,
      style: this.state.imageStyle,
    });
  }
}

ImgPreload.propTypes = {
  loadingSrc: PropTypes.string,
  errorSrc: PropTypes.string,
  src: PropTypes.string,
  loadingStyle: PropTypes.string,
  errorStyle: PropTypes.string,
  style: PropTypes.object,
};

export default ImgPreload;
