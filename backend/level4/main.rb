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

# initialize the output
outputs = { rentals: [] }

# 2- compute each rental
rentals.each do |rental|
  # select the rental car
  car_rented = cars.select { |car| car['id'] == rental['car_id'] }.first
  # create the rental
  computed_rental = Rentals.new(rental, car_rented)
  # get the id and actions of the rental
  outputs[:rentals] << {
    id: computed_rental.id,
    actions: computed_rental.actions
  }
end

# 3- store the rentals data with price
File.open('./data/output.json', 'wb') do |file|
  file.write(JSON.pretty_generate(outputs))
end
