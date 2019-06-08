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

// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {
  var $form = $("#charge-form");
  if ($form.length === 0) {
    return;
  }

  var config = $form.data("stripe");
  var handler = StripeCheckout.configure({
    key:          config.key,
    description:  config.description,
    email:        config.email,
    locale:       'auto',
    currency:     'NZD',
    name:         'CoNZealand',
    token: function(token) {
      $form.find('input#stripeToken').val(token.id);
      $form.find('input#stripeEmail').val(token.email);
      $form.submit();
    }
  });

  document.querySelector('#reservation-button').addEventListener('click', function(e) {
    e.preventDefault();

    document.querySelector('#error_explanation').innerHtml = '';

    var amount = document.querySelector('select#amount').value;
    amount = amount.replace(/\$/g, '').replace(/\,/g, '')

    amount = parseInt(amount);

    if (isNaN(amount)) {
      document.querySelector('#error_explanation').innerHtml = '<p>Please enter a valid amount in NZD ($).</p>';
    } else {
      handler.open({
        amount: amount
      })
    }
  });

  // Close Checkout on page navigation:
  window.addEventListener('popstate', function() {
    handler.close();
  });
});
