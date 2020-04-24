# frozen_string_literal: true

# Rental class
class Rentals
  attr_reader :id, :actions
  def initialize(params, params_car)
    @id = params['id']
    @time = (Date.parse(params['end_date']) - Date.parse(params['start_date']) + 1).to_i
    @distance = params['distance']
    @price_per_day = params_car['price_per_day']
    @price_per_km = params_car['price_per_km']
    @price = calculate_final_price
    @commission = calculate_commission
    @actions = []

    define_actions
  end

  private

  def define_actions
    driver_action
    owner_action
    insurance_action
    assistance_action
    drivy_action
  end

  def calculate_time_price
    # calculate time price with discount
    sum = 0
    (1..@time).each do |day|
      price = @price_per_day
      price = @price_per_day * 0.9 if day > 1 # rental time > 1 day = 10% off
      price = @price_per_day * 0.7 if day > 4 # rental time > 4 day = 30% off
      price = @price_per_day * 0.5 if day > 10 # rental time > 10 day = 50% off
      sum += price
    end
    sum
  end

  def calculate_distance_price
    @distance * @price_per_km
  end

  def calculate_final_price
    (calculate_time_price + calculate_distance_price).round
  end

  def calculate_commission
    # calculate the global commission and the amount for each partner
    commission = (@price * 30 / 100) # 30% commission
    insurance = commission / 2 # half of the commission for the insurance
    assistance = @time * 100 # 1 euro per day for the assistance
    drivy = commission - insurance - assistance # the rest for drivy
    # return an object
    {
      insurance_fee: insurance,
      assistance_fee: assistance,
      drivy_fee: drivy
    }
  end

  def driver_action
    @actions << {
      "who": 'driver',
      "type": 'debit',
      "amount": @price
    }
  end

  def owner_action
    @actions << {
      "who": "owner",
      "type": "credit",
      "amount": (@price * 70 / 100)
    }
  end

  def insurance_action
    @actions << {
      "who": "insurance",
      "type": "credit",
      "amount": @commission[:insurance_fee]
    }
  end

  def assistance_action
    @actions << {
      "who": "assistance",
      "type": "credit",
      "amount": @commission[:assistance_fee]
    }
  end

  def drivy_action
    @actions << {
      "who": "drivy",
      "type": "credit",
      "amount": @commission[:drivy_fee]
    }
  end
end
