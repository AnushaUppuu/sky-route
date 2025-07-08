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
    expect(helper.calculate_total_fare(0, 0, 3000, 2, "2025-07-20")).to eq(0)
  end

  it "calculates correctly for 25% availability and date-based pricing" do
    date = (Date.today + 10).to_s
    available_percentage = helper.percentage_seats_available(20, 5)
    seat_price = helper.seat_based_price(available_percentage, 3000)
    total_fare = seat_price * 3
    expected_total_fare = helper.days_based_price(10, total_fare).round(2)

    expect(helper.calculate_total_fare(20, 5, 3000, 3, date)).to eq(expected_total_fare)
  end

  it "calculates correctly for 75% availability and date-based pricing" do
    date = (Date.today + 20).to_s
    expected_total_fare = helper.days_based_price(20, 3000 * 2).round(2)
    expect(helper.calculate_total_fare(20, 15, 3000, 2, date)).to eq(expected_total_fare)
  end
end


  describe '#daysBefore' do
    it 'returns correct days difference' do
      date = (Date.today + 10).to_s
      expect(helper.daysBefore(date)).to eq(10)
    end

    it 'returns 0 for nil date' do
      expect(helper.daysBefore(nil)).to eq(0)
    end

    it 'returns 0 for empty date' do
      expect(helper.daysBefore("")).to eq(0)
    end

    it 'returns 0 for invalid date' do
      expect(helper.daysBefore("invalid-date")).to eq(0)
    end
  end

  describe '#days_based_price' do
    it 'returns base price if days > 15' do
      expect(helper.days_based_price(20, 1000)).to eq(1000)
    end

    it 'adds 2% per day when days between 15 and 3' do
      days = 10
      base_price = 1000
      expected = base_price + (0.02 * base_price) * days
      expect(helper.days_based_price(days, base_price)).to eq(expected)
    end

    it 'adds 10% per day when days < 3' do
      days = 2
      base_price = 1000
      expected = base_price + (0.1 * base_price) * days
      expect(helper.days_based_price(days, base_price)).to eq(expected)
    end
  end
end
