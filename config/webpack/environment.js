const { environment } = require("@rails/webpacker");
const react = require("./loaders/react");

environment.loaders.append("react", react);
module.exports = environment;
