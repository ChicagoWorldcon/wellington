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

  // Bootstrap popovers.
  //$('[data-toggle=tooltip').popover();
});

$(document).ready(() => {
  // Kiosk mode
  $(document).on('click', 'a.close-window', (e) => {
    e.preventDefault();
    window.close();
  });
});

// Javascript running on the user facing hugo pages
// If this gets complicated, consider moving to a vue.js app
$(document).ready(() => {
  // If hugo not on page, don't initialize this functionality
  const hugoShowFormInput = $('input#hugo-show-form');
  if (hugoShowFormInput.length === 0) {
    return;
  }

  // If present on the page, present privacy warning in a modal
  // This was designed for people who have > 1 membership
  $('#privacy-warning').modal();

  // Get people to type in their name to aknowledge they've read the rights.hugo.instructions
  'keyup blur change'.split(' ').forEach((event) => {
    $('#hugo-show-form').on(event, (e) => {
      const input = $(e.target).val().toLowerCase().trim();
      const expected = $(e.target).data('name').toLowerCase().trim();
      if (input === expected) {
        $('.hugo-show-form-thanks').attr('hidden', false);
      }
    });
  });

  // On ujs xhr failure, tell the user and refresh the page
  // https://github.com/rails/jquery-ujs/wiki/ajax
  $('form').on('ajax:error', () => {
    // eslint-disable-next-line no-alert
    alert('So sorry, but something went wrong. Please try one more time, then contact registrations');
    window.location.reload();
  });

  // On ujs xhr success, update heading and colours to reflect how complete their form is
  // https://github.com/rails/jquery-ujs/wiki/ajax
  $('form').on('ajax:success', (event) => {
    const jsonResponse = event.detail[0];
    const savedAt = $('<p>').addClass('l-v-spacing').text(`Saved at ${Date()}`);
    const $form = $(event.target);
    $form.find('.card-body').append(savedAt);
    const $heading = $form.closest('.card').find('.card-header');
    $heading.prop('class', jsonResponse.updated_classes);
    $heading.text(jsonResponse.updated_heading);
  });

  // Save the entire page at once in a POST request
  // This should render the page again
  $('.save-all').on('click', () => {
    const $inputs = $('#accordion input.form-control[type=text]').clone();
    const $form = $('form.edit_category').first().clone();
    $form.attr('hidden', 'true');
    $('body').append($form);
    $form.find('.card-body').first().append($inputs);
    $form.submit();
  });

  // Expand all accordions to reveal entire hugo form
  $('.open-all').on('click', () => {
    $('#accordion .collapse').addClass('show');
    $('#accordion .card-header').prop('aria-expanded', true);
  });
});
