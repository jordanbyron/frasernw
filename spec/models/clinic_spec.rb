require File.dirname(__FILE__) + '/../spec_helper'

describe Clinic do
  describe "#initialize" do
    it "should not be valid without parameters" do
      Clinic.new.should_not be_valid
    end

    it "should not be valid without name" do
      Clinic.new(:specialization_id => Specialization.first).should_not be_valid
    end

    it "should be valid with specialization" do
      Clinic.new(:specialization_id => Specialization.first, :name => 'best clinic').should be_valid
    end
  end

  describe "#ordered_clinic_locations" do
    before do
      @clinic = Clinic.create.tap do |clinic|
        clinic.clinic_locations.create.stub(:has_data?) { true }
        2.times do
          clinic.clinic_locations.create.stub(:has_data?) { false }
        end
      end
    end

    it "should return clinic locations with data first" do
      @clinic.ordered_clinic_locations[0].has_data?.should be_true
    end
  end
end
