const isProduction = process.env.NODE_ENV === "production";
const extractCSS = isProduction;

module.exports = {
  test: /\.vue(\.erb)?$/,
  loader: "vue-loader",
  options: {
    extractCSS: extractCSS,
    loaders: {
      scss: "vue-style-loader!css-loader!sass-loader"
    }
  }
};
