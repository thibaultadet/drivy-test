# frozen_string_literal: true

require 'pry-byebug'
require 'json'
require 'date'

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
  # calculate the rental time (+ 1 to include the first day)
  time = (Date.parse(rental['end_date']) - Date.parse(rental['start_date']) + 1)
  # calculate price for rental time
  time_price = time.to_i * car_rented['price_per_day']
  # calculate price for rental distance
  distance_price = rental['distance'] * car_rented['price_per_km']
  # add the id and price of rental in outputs
  outputs[:rentals] << {
    id: rental['id'],
    price: time_price + distance_price
  }
end

# 3- store the rentals data with price
File.open('./data/output.json', 'wb') do |file|
  file.write(JSON.pretty_generate(outputs))
end
