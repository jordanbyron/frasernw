require 'config/initializers/ruby_extensions/array.rb'

describe Array do

  describe "#subsets" do
    let(:ary) { [ 1, 1, 1, 2, 3, 3] }

    let(:prc) { Proc.new {|elem| elem }}

    it "returns arrays of the duplicate items" do
      expect(ary.subsets(&prc).count).to eq(3)
      expect(ary.subsets(&prc)[0]).to eq([1, 1, 1])
    end
  end
end
