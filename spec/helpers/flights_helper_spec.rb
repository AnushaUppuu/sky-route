require 'rails_helper'

RSpec.describe FlightsHelper, type: :helper do
  describe "#percentage_seats_available" do
    it "returns 0 when total seats is 0" do
      expect(helper.percentage_seats_available(0, 10)).to eq(0)
    end

    it "returns 100 when all seats are available" do
      expect(helper.percentage_seats_available(10, 10)).to eq(100.0)
    end

    it "returns 50 when half seats are available" do
      expect(helper.percentage_seats_available(20, 10)).to eq(50.0)
    end
  end

  describe "#seat_based_price" do
    let(:base_price) { 3000 }

    it "adds 50% when availability is < 25%" do
      expect(helper.seat_based_price(20, base_price)).to eq(4500.0)
    end

    it "adds 35% when availability is >= 25% and < 50%" do
      expect(helper.seat_based_price(40, base_price)).to eq(4050.0)
    end

    it "adds 20% when availability is >= 50% and < 70%" do
      expect(helper.seat_based_price(60, base_price)).to eq(3600.0)
    end

    it "returns base price when availability >= 70%" do
      expect(helper.seat_based_price(75, base_price)).to eq(3000.0)
    end
  end

  describe "#calculate_total_fare" do
    it "returns 0 when total seats is 0" do
      expect(helper.calculate_total_fare(0, 0, 3000, 2)).to eq(0)
    end

    it "calculates correctly for 25% availability" do
      expect(helper.calculate_total_fare(20, 5, 3000, 3)).to eq(12150.0)
    end

    it "calculates correctly for 75% availability" do
      expect(helper.calculate_total_fare(20, 15, 3000, 2)).to eq(6000.0)
    end
  end
end
