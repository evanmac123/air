const { dev_server: devServer } = require("@rails/webpacker").config;

const isProduction = process.env.NODE_ENV === "production";
const inDevServer = process.argv.find(v => v.includes("webpack-dev-server"));
const extractCSS =
  !(inDevServer && (devServer && devServer.hmr)) || isProduction;

module.exports = {
  test: /\.jsx?$/,
  exclude: /node_modules/,
  use: [
    {
      loader: "babel-loader",
      options: {
        presets: ["react"]
      }
    }
  ]
};
