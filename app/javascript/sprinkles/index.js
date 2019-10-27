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

// This file contains uncomplicated JavaScript. You may even consider this a dated way of doing web
// development, so feel free to submit things that depricate this in a new merge request <3

import $ from 'jquery';

import 'datatables.net-bs4';
import 'popper.js';
import 'bootstrap';

$(document).ready(() => {
  // DataTable plugin for searchable and sortable tables
  $('.js-data-table').DataTable();

  // Bootstrap tooltip for more information about elements
  $('[data-toggle=tooltip').tooltip();
});

$(document).ready(() => {
  // Kiosk mode
  $(document).on('click', 'a.close-window', (e) => {
    e.preventDefault();
    window.close();
  });
});

$(document).ready(() => {
  // Stripe form setup for accepting payments form the charges endpoints
  const $form = $('#charge-form');
  if ($form.length === 0) {
    return;
  }

  const config = $form.data('stripe');
  // n.b. Stripe is setup in a <script> tag in the layout, so should be globally available
  // eslint-disable-next-line no-undef
  const handler = StripeCheckout.configure({
    key: config.key,
    description: config.description,
    email: config.email,
    currency: config.currency,
    locale: 'auto',
    name: 'CoNZealand',
    token: (token) => {
      $form.find('input#stripeToken').val(token.id);
      $form.find('input#stripeEmail').val(token.email);
      $form.submit();
    },
  });

  document.querySelector('#reservation-button').addEventListener('click', (e) => {
    e.preventDefault();

    document.querySelector('#error_explanation').innerHtml = '';

    let amount = document.querySelector('select#amount').value;
    amount = amount.replace(/\$/g, '').replace(/,/g, '');

    amount = parseInt(amount, 10);

    if (Number.isNaN(amount)) {
      // eslint-disable-next-line no-alert
      alert("Something wen't wrong in the page. Please try refresh, and contact support if this happens again");
    } else {
      handler.open({
        amount,
      });
    }
  });

  // Close Checkout on page navigation:
  window.addEventListener('popstate', () => {
    handler.close();
  });
});

// Javascript running on the user facing hugo pages
// If this gets complicated, consider moving to a vue.js app
$(document).ready(() => {
  $('#privacy-warning').modal();

  const hugoShowFormInput = $('input#hugo-show-form');
  if (hugoShowFormInput.length === 0) {
    return;
  }

  'keyup blur change'.split(' ').forEach((event) => {
    $('#hugo-show-form').on(event, (e) => {
      const input = $(e.target).val().toLowerCase().trim();
      const expected = $(e.target).data('name').toLowerCase().trim();
      if (input === expected) {
        $('.hugo-show-form-thanks').attr('hidden', false);
      }
    });
  });
});
