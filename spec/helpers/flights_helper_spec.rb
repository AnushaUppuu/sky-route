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

  describe 'Tests related to the convert_currency method' do
    it 'Should returns the amount in US dollars for a given amount' do
      amount_in_inr = 1000
      target_currency = "USD"
      result = convert_currency(amount_in_inr, target_currency)
      expect(result[:amount]).to eq(12.0)
      expect(result[:currency]).to eq("USD")
    end

    it 'Should returns the amount in Euros for a given amount' do
      amount_in_inr = 2000
      target_currency = "EUR"
      result = convert_currency(amount_in_inr, target_currency)
      expect(result[:amount]).to eq(22.0)
      expect(result[:currency]).to eq("EUR")
    end

    it 'Should returns the amount in INR if target currency is INR' do
      amount_in_inr = 1500
      target_currency = "INR"
      result = convert_currency(amount_in_inr, target_currency)
      expect(result[:amount]).to eq(1500.0)
      expect(result[:currency]).to eq("INR")
    end

    it 'Should returns the amount in INR if target currency is unsupported' do
      amount_in_inr = 1000
      target_currency = "GBP"
      result = convert_currency(amount_in_inr, target_currency)
      expect(result[:amount]).to eq(1000.0)
      expect(result[:currency]).to eq("INR")
    end

    it 'Should returns the amount in INR if target currency is nil' do
      amount_in_inr = 500
      target_currency = nil
      result = convert_currency(amount_in_inr, target_currency)
      expect(result[:amount]).to eq(500.0)
      expect(result[:currency]).to eq("INR")
    end

    it 'Should returns the amount in INR if target currency is an empty string' do
      amount_in_inr = 750
      target_currency = ""
      result = convert_currency(amount_in_inr, target_currency)
      expect(result[:amount]).to eq(750.0)
      expect(result[:currency]).to eq("INR")
    end

    it 'Should handles lowercase currency codes by converting them to uppercase' do
      amount_in_inr = 1000
      target_currency = "usd"
      result = convert_currency(amount_in_inr, target_currency)
      expect(result[:amount]).to eq(12.0)
      expect(result[:currency]).to eq("USD")
    end
  end

  describe 'Tests related to the currency_symbol method' do
    it 'Should returns ₹ for INR' do
      expect(currency_symbol("INR")).to eq("₹")
    end

    it 'Should returns $ for USD' do
      expect(currency_symbol("USD")).to eq("$")
    end

    it 'Should returns € for EUR' do
      expect(currency_symbol("EUR")).to eq("€")
    end

    it 'Should returns ₹ for unsupported currencies' do
      expect(currency_symbol("GBP")).to eq("₹")
    end

    it 'Should returns ₹ if currency_code is an empty string' do
      expect(currency_symbol("")).to eq("₹")
    end

    it 'Should handles lowercase currency codes correctly' do
      expect(currency_symbol("usd")).to eq("$")
      expect(currency_symbol("eur")).to eq("€")
      expect(currency_symbol("inR")).to eq("₹")
    end
  end
end
