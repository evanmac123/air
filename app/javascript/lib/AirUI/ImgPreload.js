import React from "react";
import PropTypes from "prop-types";

class ImgPreload extends React.Component {
  constructor(props) {
    super(props);
    this.state = { imageLoading: true };
    this.handleImageState = this.handleImageState.bind(this);
    this.get = this.get.bind(this);
  }

  componentDidMount() {
    this.setState({
      imageSrc: this.props.loadingSrc || this.props.src,
      imageStyle: this.props.loadingStyle || this.props.style,
    });
  }

  get(prop, state) {
    const propUp = prop.replace(/^\w/, c => c.toUpperCase());
    if (state === 'load') {
      return this.props[prop] || this.props[`loading${propUp}`] || this.props[`error${propUp}`];
    }
    return this.props[`error${propUp}`] || this.props[`loading${propUp}`] || this.props[prop];
  }

  handleImageState(state) {
    this.setState({
      imageLoading: false,
      imageSrc: this.get('src', state),
      imageStyle: this.get('style', state),
    });
  }

  render() {
    return React.createElement("img", {
      className: this.props.className,
      id: this.props.id,
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
