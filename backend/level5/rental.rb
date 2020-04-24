# frozen_string_literal: true

# Rental class
class Rental
  ACTORS = %w[driver owner insurance assistance drivy].freeze
  OPTIONS = {
    gps: { price: 500, goes_to: 'owner' },
    baby_seat: { price: 200, goes_to: 'owner' },
    additional_insurance: { price: 1000, goes_to: 'drivy' }
  }.freeze

  attr_reader :id, :actions, :options
  def initialize(params, params_car, params_options)
    @id = params['id']
    @time = (Date.parse(params['end_date']) -
             Date.parse(params['start_date']) + 1).to_i
    @distance = params['distance']
    @price_per_day = params_car['price_per_day']
    @price_per_km = params_car['price_per_km']
    @actions = []
    @options = params_options

    define_actions
  end

  private

  def define_actions
    calculate_final_price
    dispatch_amounts
    # define action for each actor
    ACTORS.each { |actor| define_action(actor) }
    calculate_options_price
  end

  def calculate_options_price
    # for each rental options
    @options.each do |option|
      # finds the option's parameters
      option_params = OPTIONS[option.to_sym]
      # goes through each action to add the option price to the right actions
      @actions.each do |action|
        # always debit the driver and credit the concerned actor
        if action[:who] == option_params[:goes_to] || action[:who] == 'driver'
          action[:amount] += option_params[:price] * @time
        end
      end
    end
  end

  def calculate_time_price
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
    # calculate price for rental distance
    @distance * @price_per_km
  end

  def calculate_final_price
    # calculate the final price
    @price = (calculate_time_price + calculate_distance_price).round
  end

  def dispatch_amounts
    # calculate the global commission and the amount for each partner
    commission = (@price * 30 / 100) # 30% commission
    insurance = commission / 2 # half of the commission for the insurance
    assistance = @time * 100 # 1 euro per day for the assistance
    # return an object with dispatched debit and credit
    @dispatch = {
      driver: @price,
      owner: @price - commission, # 30% commission off
      insurance: insurance,
      assistance: assistance,
      drivy: (commission - insurance - assistance) # the rest for drivy
    }
  end

  def define_action(actor)
    # define action for each actor
    @actions << {
      who: actor,
      # only the driver is debitted
      type: actor == 'driver' ? 'debit' : 'credit',
      amount: @dispatch[actor.to_sym]
    }
  end
end
