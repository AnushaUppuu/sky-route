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

  def calculate_total_fare(total_seats, available_seats, base_price, passengers)
    return 0 if total_seats.to_i == 0
    available_percentage = percentage_seats_available(total_seats, available_seats)
    price_per_seat = seat_based_price(available_percentage, base_price)
    (price_per_seat * passengers).round(2)
  end
end
