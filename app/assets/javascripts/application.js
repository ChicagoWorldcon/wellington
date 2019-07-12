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

// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require_tree .

// If we've got test keys enabled on the site, then we'll be altering the colours to give some sense of a staging
// environment. We can turn this off to test look and feel using the button below.
$(document).ready(function initStyleToggler() {
  if (!$('body').hasClass("api-test-keys")) {
    return;
  }

  var button = $("<input>").attr({
    value: "Toggle Styles",
    title: "Stripe test keys present, this makes it clear you're in a staging environment",
    class: "btn btn-api-toggle-styles",
  });
  $("body").append(button);
  button.on("click", function() {
    $('body').toggleClass("api-test-keys");
  });
});

// Stripe form setup for accepting payments form the charges endpoints
$(document).ready(function initStripeForm() {
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
      alert("Something wen't wrong in the page. Please try refresh, and contact support if this happens again")
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

$(document).ready(function initBootstrap() {
  // DataTable plugin for searchable and sortable tables
  $(".js-data-table").DataTable();

  // Bootstrap tooltip for more information about elements
  $("[data-toggle=tooltip").tooltip();
});
