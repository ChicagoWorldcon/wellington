#!/usr/bin/env ruby

# Suppress SQL statement logging if necessary
# This is a dirty, dirty trick, but it works:
if ENV["ACTIVERECORD_HIDE_SQL"].present?
  module ActiveRecord
    class LogSubscriber
      def sql(event)
      end
    end
  end
end
