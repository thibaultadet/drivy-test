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

def calculate_time_price(time, price_per_day)
  sum = 0
  (1..time).each do |day|
    price = price_per_day
    price = price_per_day * 0.9 if day > 1 # rental time > 1 day = 10% off
    price = price_per_day * 0.7 if day > 4 # rental time > 4 day = 30% off
    price = price_per_day * 0.5 if day > 10 # rental time > 10 day = 50% off
    sum += price
  end
  sum
end

def calculate_commission(price, time)
  # calculate the global commission and the amount for each partner
  commission = (price * 30 / 100) # 30% commission
  insurance = commission / 2 # half of the commission for the insurance
  assistance = time * 100 # 1 euro per day for the assistance
  drivy = commission - insurance - assistance # the rest for drivy
  # return an object
  {
    insurance_fee: insurance,
    assistance_fee: assistance,
    drivy_fee: drivy
  }
end

# 2- calculate price
rentals.each do |rental|
  # select the rental car
  car_rented = cars.select { |car| car['id'] == rental['car_id'] }.first
  # calculate the rental time (+ 1 to include the first day)
  time = (Date.parse(rental['end_date']) -
          Date.parse(rental['start_date']) + 1).to_i
  # calculate price for rental time
  time_price = calculate_time_price(time, car_rented['price_per_day']).round
  # calculate price for rental distance
  distance_price = rental['distance'] * car_rented['price_per_km']
  # calculate final price
  price = time_price + distance_price

  # add the id and price of rental in outputs
  outputs[:rentals] << {
    id: rental['id'],
    price: price,
    commission: calculate_commission(price, time)
  }
end

# 3- store the rentals data with price
File.open('./data/output.json', 'wb') do |file|
  file.write(JSON.pretty_generate(outputs))
end
