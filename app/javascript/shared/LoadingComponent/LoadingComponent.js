import React from "react";

const loadingContainerStyle = {
  width: "100%",
  display: "inline-block",
  textAlign: "center",
  marginTop: "10%",
};

const spinnerStyle = {
  color:"#48BFFF",
  marginTop: "30px",
};

const LoadingComponent = () => (
  <div className="loading-container" style={loadingContainerStyle}>
    <i className="fa fa-spinner fa-spin fa-3x" style={spinnerStyle}></i>
  </div>
);

export default LoadingComponent;
