/* eslint no-console: 0 */

// Copyright 2020 Matthew B. Gray
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import $ from 'jquery';
import Vue from 'vue/dist/vue.esm';
import App from '../finalists/app.vue';

document.addEventListener('DOMContentLoaded', () => {
  $.getJSON(window.location.path, (json, state) => {
    if (state !== 'success') {
      // eslint-disable-next-line no-alert
      alert("Something wen't wrong in the page. Please try refresh, and contact support if this happens again");
      window.location.reload();
    }

    window.app = new Vue({
      el: '#finalist-form',
      components: {
        finalists: App,
      },
      data: {
        categories: json.categories,
      },
    });
  });
});
