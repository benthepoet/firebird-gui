const { resolve } = require('path');

const PUBLIC_PATH = resolve(__dirname, 'client/public');
const SRC_PATH = resolve(__dirname, 'client/src');

module.exports = {
  entry: `${SRC_PATH}/index.js`,
  output: {
    filename: 'bundle.js',
    path: PUBLIC_PATH
  },
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: 'elm-webpack-loader',
          options: {}
        }
      },
      {
        test: /\.css$/,
        use: [
          {
            loader: 'style-loader'
          }, 
          {
            loader: 'css-loader'
          }
        ]
      }
    ]
  },
  devServer: {
    contentBase: PUBLIC_PATH,
    disableHostCheck: true,
    proxy: {
      '/ws': {
         target: 'ws://localhost:8920',
         ws: true
      }
    }
  }
};