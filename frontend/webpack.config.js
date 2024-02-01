const path = require('path')
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const TerserPlugin = require('terser-webpack-plugin');

module.exports = ({development}) => ({
  entry: {
    'wfs-frontend': './index.js',
  },
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: '[name].min.js',
    libraryTarget: "umd",
  },
  target: ['web', 'es5'],

  mode: development ? 'development' : 'production',

  optimization: {
    minimizer: development ? [] : [new TerserPlugin()],
  },
  resolve: {
    alias: {
      'vue$': 'vue/dist/vue.esm.js'
    }
  },

  module: {
    rules: [
      {
        test: /\.css$/i,
        use: [MiniCssExtractPlugin.loader, "css-loader"],
      },
    ],
  },
  devtool: 'cheap-source-map',
  plugins: [
    new MiniCssExtractPlugin({
      filename: '[name].min.css'
    })
  ]
});
