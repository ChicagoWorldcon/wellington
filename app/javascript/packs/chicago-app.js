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

// Rails defaults
// Register theme with webpacker, allows us to use styles with stylesheet_pack_tag
import ujs from '@rails/ujs';
import * as activeStorage from '@rails/activestorage';
import 'core-js/stable';
import 'regenerator-runtime/runtime';

import '../stylesheets/chicago-styles.scss';
import '../channels';
import '../sprinkles';
import '@fortawesome/fontawesome-free/js/brands';
import '@fortawesome/fontawesome-free/js/fontawesome';
import '@fortawesome/fontawesome-free/js/regular';
import '@fortawesome/fontawesome-free/js/solid';

const images = require.context('../images', true);

ujs.start();
activeStorage.start();

// eslint-disable-next-line no-console
console.log('Hello from chicago.js');
