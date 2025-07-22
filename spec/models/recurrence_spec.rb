require 'rails_helper'

RSpec.describe Recurrence, type: :model do
  it "creates a recurrence type" do
    recurrence = Recurrence.new(recurrence_type: "daily")
    expect(recurrence.save).to be true
  end
end
