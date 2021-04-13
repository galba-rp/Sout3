require "spec_helper"
require "pry"

RSpec.describe HouseSanitizer do
data = {
      price: "123 000 $",
      surface: "217M²",
      city: "Vannes 56000",
      postCode: "",
      energy: " b ",
      year: "1767"
}

house = described_class.new(data)
  
  describe "#clean surface" do
    it "returns 217" do
      surface = house.cleanSurface

      expect(surface).to eql(217)
        end
  end

  describe "#clean price" do
    it "returns 123000" do
      price = house.cleanPrice

      expect(price).to eql(123000)
        end
  end

  describe "clean post code" do
    it "returns 56000" do
      pc = house.cleanPostcode

      expect(pc).to eql(56000)
    end
  end

  describe "#clean city name" do
    it "returns Vannes" do
      name = house.cleanCityName

      expect(name).to eql("Vannes")
    end
  end

  describe "#clean year" do
    it "returns 1767" do
      year = house.cleanYear

      expect(year).to eql(1767)
    end
  end

  describe "#clean energy" do
    it "returns B" do
      energy = house.cleanEnergy

      expect(energy).to eql("B")
    end
  end

  
end