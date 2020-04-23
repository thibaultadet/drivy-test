# frozen_string_literal: true

require 'pry-byebug'
require 'json'
require 'date'
require_relative 'rentals'

# 1- get the data from the input
filepath = './data/input.json'
inputs = JSON.parse(File.read(filepath))
cars = inputs['cars']
rentals = inputs['rentals']

# initialize the output
outputs = { rentals: [] }

# 2- calculate price
rentals.each do |rental|
  # select the rental car
  car_rented = cars.select { |car| car['id'] == rental['car_id'] }.first
  computed_rental = Rentals.new(rental, car_rented)
  p computed_rental
  outputs[:rentals] << {
    "id": computed_rental.id,
    "actions": computed_rental.actions
  }
end

# 3- store the rentals data with price
File.open('./data/output.json', 'wb') do |file|
  file.write(JSON.pretty_generate(outputs))
end
