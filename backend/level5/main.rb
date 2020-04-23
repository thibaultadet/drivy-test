# frozen_string_literal: true

require 'pry-byebug'
require 'json'
require 'date'
require_relative 'rental'

# 1- get the data from the input
filepath = './data/input.json'
inputs = JSON.parse(File.read(filepath))

cars = inputs['cars'] # get the cars
rentals = inputs['rentals'] # get the rentals
options = inputs['options'] # get the options

# initialize the output
outputs = { rentals: [] }

# 2- compute each rental
rentals.each do |rental|
  # select the rental car
  car_rented = cars.select { |car| car['id'] == rental['car_id'] }.first
  # select the rental options
  rental_options = options.select { |option| option['rental_id'] == rental['id'] }
                          .map { |option| option['type'] } # get only the type
  # create the rental
  computed_rental = Rental.new(rental, car_rented, rental_options)
  # get the id, options and actions of the rental
  outputs[:rentals] << {
    id: computed_rental.id,
    options: computed_rental.options,
    actions: computed_rental.actions
  }
end

# 3- store the rentals data with price
File.open('./data/output.json', 'wb') do |file|
  file.write(JSON.pretty_generate(outputs))
end
