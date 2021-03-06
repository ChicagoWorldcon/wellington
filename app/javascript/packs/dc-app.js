/*
 * Copyright 2020 Matthew B. Gray
 * Copyright 2021 Fred Bauer
 *
 * Licensed under the Apache License, Version 2.0
 */
/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// Rails defaults
// Register theme with webpacker, allows us to use styles with stylesheet_pack_tag
import ujs from '@rails/ujs';
import * as activeStorage from '@rails/activestorage';
import 'core-js/stable';
import 'regenerator-runtime/runtime';

import '../stylesheets/dc-styles.scss';
import '../channels';
import '../sprinkles';
import '@fortawesome/fontawesome-free/js/brands';
import '@fortawesome/fontawesome-free/js/fontawesome';
import '@fortawesome/fontawesome-free/js/regular';
import '@fortawesome/fontawesome-free/js/solid';
require.context('../images', true);

ujs.start();
activeStorage.start();

// eslint-disable-next-line no-console
console.log('Hello from DC.js');


