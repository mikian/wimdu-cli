require 'sequel'
require 'securerandom'

module Wimdu
  class DB
    attr_reader :db

    def initialize
      @db = Sequel.sqlite('./.wimdu.db')

      # Perform migrations
      migrate
    end

    def properties(inactive = false)
      @db[:properties].where()
    end

    def property(id = nil)
      if id.nil?
        Property.new
      end
    end

    private
    def migrate
      unless @db.table_exists?('properties')
        @db.create_table(:properties) do
          primary_key :id
          String  :uuid
          String  :title
          Integer :type
          String  :address
          Float   :rate
          Integer :max_guests
          String  :email
          String  :phone
          Boolean :active
        end
      end
    end

  end

  class Property
    attr_reader :id, :uuid
    attr_accessor :title, :type, :address, :rate, :max_guests, :email, :phone, :active

    def initialize(attributes = {})
      attributes.each {|key, value| self.send("#{key}=", value) }

      @uuid   ||= SecureRandom.hex(4).upcase
      @active ||= false
    end

  end
end
