require 'config/initializers/ruby_extensions/array.rb'

describe Array do

  describe "#subsets" do
    let(:ary) { [ 1, 1, 1, 2, 3, 3] }

    let(:prc) { Proc.new {|elem| elem }}

    it "returns arrays of the duplicate items" do
      ary.subsets(&prc).count.should == 3
      ary.subsets(&prc)[0].should == [1, 1, 1]
    end
  end
end
