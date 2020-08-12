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

# GlooContact has methods for both looking up a remote user in Gloo
# and also saving our local representation to the remote
# the complete 'saved state' is on the remote or assumed to be default
class GlooContact
  # ServiceUnavailable can be raised when endpoints are unavailable
  class ServiceUnavailable < StandardError
  end

  # Magic strings agreed to on this roles register document:
  # https://docs.google.com/spreadsheets/d/1L-nWrdgpLJOKJu6ZKvQ0ssXiKv8GdTcsooFc5ymT4mo/edit#gid=441845492
  MEMBER_ATTENDING = "M_Attending"
  MEMBER_VOTING = "M_Voting"
  MEMBER_HUGO = "M_HUGO"
  DISCORD_ROLES = %w(
    Discord_ServerMod
    Discord_PlatMod
    Discord_Experience_support
    Discord_Exec
    Discord_ConCom
    Discord_Mission_Control
    Discord_Tech_staff
    Discord_Staff
    Discord_Crew
    Discord_Treasury
  )

  attr_reader :user

  def initialize(user)
    @user = user
  end

  # remote_state hits gloo APIs and returns a representation of the user.
  # Because roles are not attached to users in the current API But this is
  # expected when you post them back I'm trying to keep this symetric so you
  # can compare what we'll post vs what the remote has.
  def remote_state
    return @remote_state if @remote_state.present?

    remote_user = get_json("/v1/users/#{user.email}")
    remote_roles = get_json("/v1/users/#{user.email}/roles")
    @remote_state = remote_user.merge(remote_roles)
  rescue SocketError
    raise ServiceUnavailable.new("Gloo isn't accepting connections on #{base_url}")
  end

  # local_state uses models associated with a user's reservation to assemble a
  # representation of the user. Note, we only know if DISCORD_ROLES are set if
  # they come back from Gloo Treating REST responses as IO because iwe don't
  # actually know what these systems are but do need to advise them of their roles.
  def local_state
    if allow_login?
      {
        id: user.id.to_s,
        email: user.email,
        expiration: nil,
        name: conzealand_contact.to_s,
        display_name: conzealand_contact.badge_display,
        roles: local_roles,
      }
    else
      # stub result which looks like 404 response from TFN
      {
        "roles": []
      }
    end
  end

  def local_roles
    return @local_roles unless @local_roles.nil?

    @local_roles = discord_roles.dup

    if reservation.present?
      # Alphabetical, follows what we get back from TFN
      @local_roles << MEMBER_ATTENDING if reservation.can_attend?
      @local_roles << MEMBER_HUGO if reservation.can_attend? || reservation.membership.community?
      @local_roles << MEMBER_VOTING if reservation.can_vote?
    end

    @local_roles
  end

  def discord_roles
    return @discord_roles unless @discord_roles.nil?

    @discord_roles = remote_state[:roles] || []
    @discord_roles = @discord_roles & DISCORD_ROLES
  end

  def discord_roles=(new_roles)
    @discord_roles = new_roles & DISCORD_ROLES
  end

  def in_sync?
    local_state == remote_state
  end

  def conzealand_contact
    if reservation.nil?
      contact_without_reservation
    else
      reservation.active_claim.conzealand_contact || contact_without_details
    end
  end

  def save!
    if allow_login?
      post_json("/v1/users", local_state)
    else
      delete_json("/v1/users/#{user.email}")
    end
  end

  def reservation
    @reservation ||= user.reservations.paid.order(:created_at).first
  end

  private

  def allow_login?
    reservation.present? && local_roles.any?
  end

  def contact_without_reservation
    ConzealandContact.new(
      first_name: "Disabled #{user.email}"
    )
  end

  def contact_without_details
    ConzealandContact.new(
      first_name: "CoNZealand Super Fan ##{reservation.membership_number}"
    )
  end

  # get_json hits a url using standard auth headers and parses the response body
  # from json to a ruby hash. If the service is down, raises an error.
  def get_json(path)
    url = [base_url, path].join
    resp = HTTParty.get(url, headers: standard_headers)
    parse_json(url, resp)
  end

  # post_json takes a ruby hash and converts it to a json post body
  # responses are translated from json back to a ruby hash. If the service
  # is down, raises an error.
  def post_json(path, body)
    url = [base_url, path].join
    resp = HTTParty.post(url, headers: standard_headers, body: body.to_json)
    parse_json(url, resp)
  end

  # delete_json takes a path and calles HTTP delete on it
  # this is used when we want to make sure a user is removed TFN
  def delete_json(path)
    url = [base_url, path].join
    resp = HTTParty.delete(url, headers: standard_headers)
    parse_json(url, resp)
  end

  # parse_json takes a response and parses the body if it can
  # raises a ServiceUnavailable if response code not supported
  def parse_json(url, resp)
    case resp.code
    when 200
      JSON.parse(resp.body, symbolize_names: true)
    when 404
      {}
    else
      raise ServiceUnavailable.new("#{url} failed with #{resp.code}")
    end
  end

  def standard_headers
    {
      "Content-Type" => "application/json",
      "Authorization" => ENV.fetch("GLOO_AUTHORIZATION_HEADER"),
    }
  end

  def base_url
    ENV.fetch("GLOO_BASE_URL")
  end
end
