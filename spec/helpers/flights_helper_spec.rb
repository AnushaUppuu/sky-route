require 'rails_helper'

RSpec.describe FlightsHelper do
  include FlightsHelper  # ✅ Include correct helper module

  describe '#daysBefore' do
    it 'returns correct days difference' do
      date = (Date.today + 10).to_s
      expect(daysBefore(date)).to eq(10)
    end

    it 'returns 0 for nil date' do
      expect(daysBefore(nil)).to eq(0)
    end

    it 'returns 0 for empty date' do
      expect(daysBefore("")).to eq(0)
    end

    it 'returns 0 for invalid date' do
      expect(daysBefore("invalid-date")).to eq(0)
    end
  end

  describe '#days_based_price' do
    it 'returns base price if days > 15' do
      expect(days_based_price(20, 1000)).to eq(1000)
    end

    it 'adds 20% per day when days between 15 and 3' do
      days = 10
      base_price = 1000
      expected = base_price + (0.2 * base_price) * days
      expect(days_based_price(days, base_price)).to eq(expected)
    end

    it 'adds 10% per day when days < 3' do
      days = 2
      base_price = 1000
      expected = base_price + (0.1 * base_price) * days
      expect(days_based_price(days, base_price)).to eq(expected)
    end
  end
end
