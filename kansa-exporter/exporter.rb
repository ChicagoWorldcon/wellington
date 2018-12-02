require "rubygems"
require "bundler/setup"
require "active_record"
require "pry"

# Import ruby classes
project_root = File.dirname(File.absolute_path(__FILE__))
%w(models services).each do |type|
  Dir.glob(project_root + "/app/#{type}/*.rb").each{ |f| require f }
end

# Set up active record connection
if !ENV["DATABASE_URL"].nil?
  ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
else
  connection_details = YAML::load(File.open('config/database.yml'))
  ActiveRecord::Base.establish_connection(connection_details)
end

if __FILE__ == $0
  puts ExportPeople.new.call
end
