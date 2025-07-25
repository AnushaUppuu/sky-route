module FlightsHelper
  def percentage_seats_available(total_seats, available_seats)
    return 0 if total_seats.to_i == 0
    (available_seats.to_f / total_seats.to_f * 100).round(2)
  end

  def seat_based_price(available_percentage, base_price)
    if available_percentage < 25
      base_price + (0.5 * base_price)
    elsif available_percentage >= 25 && available_percentage < 50
      base_price + (0.35 * base_price)
    elsif available_percentage >= 50 && available_percentage < 70
      base_price + (0.2 * base_price)
    else
      base_price
    end
  end
  def daysBefore(date)
    return 0 if date.nil? || date.empty?
    begin
      flight_date = Date.parse(date)
      (flight_date - Date.today).to_i
    rescue ArgumentError
      0
    end
  end
  def days_based_price(days, base_price)
    if days>15
      base_price
    elsif days <= 15 && days >= 3
      base_price + (0.02 * base_price)* days
    else
      base_price + (0.1 * base_price)* days
    end
  end
  def calculate_total_fare(total_seats, available_seats, base_price, passengers, date)
    return 0 if total_seats.to_i == 0
    available_percentage = percentage_seats_available(total_seats, available_seats)
    price_per_seat = seat_based_price(available_percentage, base_price)

    total_fare = price_per_seat

    days = daysBefore(date)
    total_fare_with_date_pricing = days_based_price(days, total_fare)*passengers

    total_fare_with_date_pricing.round(2)
  end
  def convert_currency(amount_in_inr, target_currency)
    exchange_rates = {
      "INR" => 1.0,
      "USD" => 0.012,
      "EUR" => 0.011
    }
    target_currency = target_currency.to_s.upcase
    target_currency = "INR" if target_currency.empty? || !exchange_rates.key?(target_currency)
    rate = exchange_rates[target_currency]
    converted_amount = amount_in_inr * rate
    {
      amount: converted_amount.round(2),
      currency: target_currency
    }
  end
  def currency_symbol(currency_code)
    symbols = {
      "INR" => "₹",
      "USD" => "$",
      "EUR" => "€"
    }
    symbols[currency_code.upcase] || "₹"
  end
end
