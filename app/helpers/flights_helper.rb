module FlightsHelper
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
          base_price + (0.2 * base_price)* days
        else
          base_price + (0.1 * base_price)* days
        end
      end
end
