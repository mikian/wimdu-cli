require 'sequel'

# Initialize DB
DB = Sequel.sqlite('./.wimdu.db')
unless DB.table_exists?('properties')
  DB.create_table(:properties) do
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

class Property < Sequel::Model
  plugin :validation_helpers

  def validate
    super

    errors.add(:title, 'cannot be empty')     if !title.nil? && title.length == 0
    errors.add(:address, 'cannot be empty')   if !address.nil? && address.length == 0
    errors.add(:rate, 'must be number')       if !rate.nil? && !rate.to_s.match(/\A\d+\.\d*\Z/)
    errors.add(:max_guests, 'must be number') if !max_guests.nil? && !max_guests.to_s.match(/\A\d+\Z/)
  end

  def before_create
    begin
      self.uuid = SecureRandom.hex(4).upcase
    end while Property.first(uuid: self.uuid)

    super
  end
end

class CLI < Thor
  include Thor::Actions

  desc "new", "Creates a new property"
  def new
    @property = Property.create(active: false)
    say("Starting with new property #{@property.uuid}.")

    fill_data(@property)
  end

  desc "continue ID", "Continues filling property information"
  def continue(uuid)
    @property = Property.first(uuid: uuid)
    say("Continuing with #{@property.uuid}")

    fill_data(@property)
  end

  desc "list", "Lists all available properties"
  def list
    say "Found #{Property.count(active: true)} offer(s)."

    Property.where(active: true).each do |prop|
      say "#{prop.uuid}: #{prop.title}"
    end
  end

  private
  def fill_data(property)
    attributes = {
      title: 'Title:',
      address: 'Address:',
      rate: 'Nightly rate in EUR:',
      max_guests: 'Max guests:',
      email: 'Email:',
      phone: 'Phone number:',
    }

    attributes.each {|a, q| ask_and_save(property, a, q)}

    # Assume all data is entered properly
    property.active = true
    property.save

    say("Great job! Listing #{property.uuid} is complete!")
  end

  def ask_and_save(property, attribute, question)
    if property.send(attribute).nil?
      begin
        if property.errors[attribute]
          say("Error: #{attribute.capitalize} #{property.errors[attribute].join(', ')}")
        end

        property.send("#{attribute}=", ask(question))
      end while !property.valid?
      property.save
    end
  end
end
