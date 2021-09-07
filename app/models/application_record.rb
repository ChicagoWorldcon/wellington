# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
# Copyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0
# 9-Mar-2021 FNB Addd strip_attributes to remove all leading and trailing spaces, and strip blank vales to NIL.

# ApplicationRecord is an abstract class which anything which saves to Postgres relies on.
# It's configured through config/database.yml and inherited by most things in the models directory
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  strip_attributes :collapse_spaces => true

  protected

  # CoNZealand only thing, this'll do nothing unless configured
  def gloo_sync
    return if Rails.env.test?                                 # guard against trigger background jobs from specs
    return unless ENV["GLOO_BASE_URL"].present?               # guard against sync unless configured
    return unless Claim.contact_strategy == ConzealandContact # guard against sync unless conzealand specifically
    return unless gloo_lookup_user.present?                   # guard against sync if we can't associate a user with this model

    GlooSync.perform_async(gloo_lookup_user.email)
  end
end
