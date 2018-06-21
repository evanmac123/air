const { environment } = require("@rails/webpacker");
const react = require("./loaders/react");
const erb = require("./loaders/erb");

environment.loaders.append("react", react);
environment.loaders.append("erb", erb);
module.exports = environment;
