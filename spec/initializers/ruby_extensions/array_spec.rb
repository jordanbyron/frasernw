require 'spec_helper'

describe Array do

  describe "#dupe_sets" do
    let(:ary) { [ 1, 1, 1, 2, 3, 3] }

    let(:prc) { Proc.new {|elem| elem }}

    it "returns arrays of the duplicate items" do
      ary.dupe_sets(prc).count.should == 2
      ary.dupe_sets(prc)[0].should == [1, 1, 1]
    end
  end
end
