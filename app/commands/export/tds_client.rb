# frozen_string_literal: true

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

# Export::TdsClient represents an abstraction over a connection to Microsoft SQL Server
# You can mix these into anything that needs to execute SQL without worrying about details of the connection
module Export::TdsClient
  def execute(sql_template, *args)
    safe_args = args.flatten.map { |a| a.is_a?(String) ? client.escape(a) : a }
    sql_query = sprintf(sql_template, *safe_args)
    puts sql_query if verbose?
    client.execute(sql_query)
  end

  def client
    @client ||= TinyTds::Client.new(
      username: ENV["TDS_USER"],
      password: ENV["TDS_PASSWORD"],
      host: ENV["TDS_HOST"],
      database: ENV["TDS_DATABASE"],
    )
  end

  def verbose?
    @verbose.present?
  end
end
