require 'wimdu/db'

module Wimdu
  class CLI < Thor
    include Thor::Actions

    desc "list", "Lists all available properties"
    def list
      @db = Wimdu::DB.new

      properties = @db.properties

      say "Found #{properties.count} offer(s)."

      properties.each do |prop|
        say "#{prop.uuid}: #{prop.title}"
      end
    end
  end
end
