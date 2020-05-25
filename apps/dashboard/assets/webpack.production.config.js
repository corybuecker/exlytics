const path = require("path");
const TerserPlugin = require("terser-webpack-plugin");
const ManifestPlugin = require('webpack-manifest-plugin');

manifestOptions = {
  generate: (seed, files, entrypoints) => {
    const digests = files.reduce((manifest, { name, path: absPath, chunk }) => {
      const relPath = absPath.split(path.sep).slice(1).join(path.sep)

      manifest[relPath] = {
        digest: chunk.contentHash.javascript,
        logical_path: `js/${name}`
      }

      return manifest
    }, {})

    const latest = files.reduce((manifest, { name, path: absPath, chunk }) => {
      const relPath = absPath.split(path.sep).slice(1).join(path.sep)
      manifest[`js/${name}`] = relPath

      return manifest
    }, {})

    return { digests, latest, version: 1 }
  }
}

module.exports = {
  mode: "production",
  entry: "./src/index.tsx",
  output: {
    publicPath: "/js/",
    filename: "[name].[contenthash].js",
    chunkFilename: "[name].[contenthash].js",
    path: path.resolve(__dirname, "../priv/static/js"),
  },
  devtool: "source-map",
  optimization: {
    minimize: true,
    minimizer: [new TerserPlugin()],
  },
  plugins: [
    new ManifestPlugin(manifestOptions)
  ],
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        exclude: /node_modules/,
        use: {
          loader: "ts-loader",
          options: {
            transpileOnly: true,
          },
        },
      },
      {
        test: /\.scss$/,
        use: ["style-loader", "css-loader", "sass-loader"],
      },
    ],
  },
};
