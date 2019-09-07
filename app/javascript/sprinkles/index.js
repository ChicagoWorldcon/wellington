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

// This file contains uncomplicated JavaScript. You may even consider this a dated way of doing web development, so feel
// free to submit things that depricate this in a new merge request <3

import $ from 'jquery'
import DataTable from 'datatables.net-bs4'
import popper from 'popper.js'
import bootstrap from 'bootstrap'

$(document).ready(() => {
  // DataTable plugin for searchable and sortable tables
  $(".js-data-table").DataTable();

  // Bootstrap tooltip for more information about elements
  $("[data-toggle=tooltip").tooltip();
});

$(document).ready(() => {
  // Kiosk mode
  $(document).on("click", "a.close-window", (e) => {
    e.preventDefault();
    window.close()
  });
});

$(document).ready(() => {
  // Stripe form setup for accepting payments form the charges endpoints
  var $form = $("#charge-form");
  if ($form.length === 0) {
    return;
  }

  var config = $form.data("stripe");
  var handler = StripeCheckout.configure({
    key:          config.key,
    description:  config.description,
    email:        config.email,
    currency:     config.currency,
    locale:       'auto',
    name:         'CoNZealand',
    token: (token) => {
      $form.find('input#stripeToken').val(token.id);
      $form.find('input#stripeEmail').val(token.email);
      $form.submit();
    }
  });

  document.querySelector('#reservation-button').addEventListener('click', (e) => {
    e.preventDefault();

    document.querySelector('#error_explanation').innerHtml = '';

    var amount = document.querySelector('select#amount').value;
    amount = amount.replace(/\$/g, '').replace(/\,/g, '')

    amount = parseInt(amount);

    if (isNaN(amount)) {
      alert("Something wen't wrong in the page. Please try refresh, and contact support if this happens again")
    } else {
      handler.open({
        amount: amount
      })
    }
  });

  // Close Checkout on page navigation:
  window.addEventListener('popstate', () => {
    handler.close();
  });
});

$(document).ready(() => {
  // If we've got test keys enabled on the site, then we'll be altering the colours to give some sense of a staging
  // environment. We can turn this off to test look and feel using the button below.
    if (!$('body').hasClass("api-test-keys")) {
    return;
  }

  var button = $("<input>").attr({
    value: "Toggle Styles",
    title: "Stripe test keys present, this makes it clear you're in a staging environment",
    class: "btn btn-api-toggle-styles",
  });
  $("body").append(button);
  button.on("click", () => {
    $('body').toggleClass("api-test-keys");
  });
});
