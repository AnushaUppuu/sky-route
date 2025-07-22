require 'rails_helper'

RSpec.describe Airport, type: :model do
  it "creates an airport successfully" do
    airport = Airport.new(
      name: "Kempegowda International Airport",
      code: "BLR",
      city: "Bangalore",
      country: "India"
    )

    expect(airport.save).to be true
  end
end
