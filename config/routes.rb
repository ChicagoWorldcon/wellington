# frozen_string_literal: true

# Copyright 2019 Andrew Esler (ajesler)
# Copyright 2019 Steven C Hartley
# Copyright 2020 Matthew B. Gray
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

require "sidekiq/web"
require "sidekiq-scheduler/web"

# For more information about routes, see https://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  root to: "landing#index"

  # Sidekiq is our jobs server and keeps tabs on backround tasks
  if ENV["SIDEKIQ_USER"].present? && ENV["SIDEKIQ_PASSWORD"].present?
    # Mounting /sidekiq with basic auth
    mount Sidekiq::Web, at: "/sidekiq"

    Sidekiq::Web.use Rack::Auth::Basic  do |username, password|
      user_provided = ::Digest::SHA256.hexdigest(username)
      user_expected = ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USER"])

      password_provided = ::Digest::SHA256.hexdigest(password)
      password_expected = ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"])

      user_ok = ActiveSupport::SecurityUtils.secure_compare(user_provided, user_expected)
      password_ok = ActiveSupport::SecurityUtils.secure_compare(password_provided, password_expected)

      (user_ok && password_ok)
    end
  elsif ENV["SIDEKIQ_NO_PASSWORD"].present?
    # Mounting /sidekiq without password
    mount Sidekiq::Web, at: "/sidekiq"
  else
    # Not mounting /sidekiq
  end

  # Sets routes for account management actions.
  # This order seems to matter for tests.
  devise_for :users
  devise_for :supports

  get "/login/:email/:key", to: "user_tokens#kansa_login_link", email: /[^\/]+/, key: /[^\/]+/
  resources :user_tokens, only: [:new, :show, :create], id: /[^\/]+/ do
    get :logout, on: :collection
  end

  get '/cart', to: 'cart#show', as: 'cart'
  get '/cart/purchase_preview', to: 'cart#purchase_preview', as: 'purchase_preview'
  post '/cart/pay_online', to: 'cart#pay_online', as: 'pay_online'
  post '/cart/pay_with_cheque', to: 'cart#pay_with_cheque', as: 'pay_with_cheque'
  put '/cart/verify', to: 'cart#verify_availability', as: 'verify_all'
  delete '/cart/clear', to: 'cart#destroy', as: 'clear_all'


  scope :cart, only: [:show, :create, :edit, :update] do
    resources :cart_items, only: [:index, :show, :edit, :update] do
      get 'index_current_cart_items', :on => :collection, as: 'current_cart_items'
      get 'edit_membership', :on => :member
      get 'edit_recipient', :on => :member
      put 'update_membership', :on => :member
      put 'update_recipient', :on => :member
      patch 'verify_single_item_availablility', :on => :member, to: 'cart#verify_single_item_availability', as: 'verify_single'
      delete 'remove_single_item', :on => :member, to: 'cart#remove_single_item', as: 'remove_single'
      patch 'save_item_for_later', :on => :member, to: 'cart#save_item_for_later', as: 'save_single'
      patch 'move_item_to_cart', :on => :member, to: 'cart#move_item_to_cart', as: 'move_single'
    end
  end

  match 'cart_items/create' => 'cart_items#create', via: :post, :as => 'create_item'
  resources :credits
  resources :landing
  resources :memberships
  resources :themes
  resources :upgrades
  resources :hugo_packet, id: /[^\/]+/


  resources :reservations do
    post :reserve_with_cheque, on: :collection
    post :add_reservation_to_cart, on: :collection, to: 'cart#add_reservation_to_cart', as: 'add_to_cart'
    resources :charges
    resources :finalists, id: /[^\/]+/
    resources :nominations, id: /[^\/]+/
    resources :upgrades
  end



  # /operator are maintenance routes for support people
  scope :operator do
    resources :reservations do
      resources :credits
      resources :set_memberships
      resources :transfers, id: /[^\/]+/
      resources :rights
    end
  end
end
