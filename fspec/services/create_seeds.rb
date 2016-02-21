require 'app/services/create_seeds'

RSpec.describe CreateSeeds::Table do

  describe "#contains_identifying_info" do
    context "string contains identifying info" do
      it "should return true" do
        obj = CreateSeeds::Table.new(klass: Object)

        [
          "Dr. Brown is at this location",
          "The phone number is 123-234-2345",
          "Their email is asdf@asdf.com",
          "Katrina Zhang is the primary physician"
        ].each do |string|
          expect(obj.contains_identifying_info?(string)).to eq(true)
        end
      end
    end
  end
end
