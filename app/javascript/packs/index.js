import React from "react";
import ReactDOM from "react-dom";

import "./index.css";
import App from "./App";
import dispatcher from "../legacy/dispatcher";

console.log("Welcome to Airbo 🎉");
console.log(dispatcher());

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(<App />, document.getElementById("root"));
});
