# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 AJ Esler
# Copyright 2020 Victoria Garcia
# Copyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# 1-Oct-21 FNB Modified to allow for Site Selection

module ChargesHelper

  include ApplicationHelper

  def stripe_config(reservation)
    {
      key: Rails.configuration.stripe[:publishable_key],
      description: "#{worldcon_public_name} #{@membership.name} membership",
      email: reservation.user.email,
      name: worldcon_public_name_spaceless,
      currency: $currency,
    }.to_json
  end

  def stripe_config_site(reservation)
    {
      key: Rails.configuration.stripe[:publishable_key],
      description: "#{worldcon_public_name} Site Selection",
      email: reservation.user.email,
      name: worldcon_public_name_spaceless,
      currency: $currency,
    }.to_json
  end
end
