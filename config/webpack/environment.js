/*
 * Copyright 2019 Matthew B. Gray
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

const { environment } = require('@rails/webpacker');
const { VueLoaderPlugin } = require('vue-loader');
const vue = require('./loaders/vue');
const webpack = require('webpack');


environment.plugins.prepend('jQuery', new webpack.ProvidePlugin({
  jQuery: 'jquery',
  $: 'jquery',
}));
environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vue)
module.exports = environment;

// resolve-url-loader must be used before sass-loader
environment.loaders.get('sass').use.splice(-1, 0, {
  loader: 'resolve-url-loader'
})
