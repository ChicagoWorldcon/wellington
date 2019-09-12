# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

# Be sure to restart your server when you modify this file.
Rails.application.config.content_security_policy do |policy|
  static_hosts = []
  static_hosts << "https://checkout.stripe.com" if ENV["STRIPE_PUBLIC_KEY"].present?

  api_endpoints = []
  api_endpoints << "http://localhost:3035" if Rails.env.development?
  api_endpoints << "ws://localhost:3035" if Rails.env.development?

  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.script_src  :self, :https, *static_hosts
  policy.style_src   :self, :https

  policy.connect_src :self, :https, *api_endpoints

  # Specify URI for violation reports
  policy.report_uri "/csp-violation-report-endpoint"
end

# Allow CSP to report but not enforce violations to the configured URL
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true

# Inline script workaround, if you are using UJS then enable automatic nonce generation
# Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
