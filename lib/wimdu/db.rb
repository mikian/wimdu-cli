require 'sequel'

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
end
