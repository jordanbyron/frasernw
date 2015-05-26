require 'lib/hash_table'
require 'lib/analytics/totaler/base'
require 'lib/analytics/totaler/sum'
require 'active_support/core_ext/hash/slice'

describe Analytics::Reducer::User do
  let(:sample_data) do
    [
      {:user_type_key=>"-1", :division_id=>"-1", :users=>2},
      {:user_type_key=>"-1", :division_id=>"2", :users=>1},
      {:user_type_key=>"-1", :division_id=>"3", :users=>2},
      {:user_type_key=>"0", :division_id=>"1", :users=>6}
    ]
  end
  let(:sample_table) do
    HashTable.new(sample_data)
  end

  describe "exec" do
    it "should return totals" do
      totaler = Analytics::Totaler::Sum.new(
        sample_table,
        dimensions: [ :user_type_key, :division_id ],
        metric: :users
      )

      expect(totaler.totals).to contain_exactly(
        {:user_type_key=>"-1", :users=>5},
        {:user_type_key=>"0",  :users=>6},
        {:division_id=>"-1", :users=>2},
        {:division_id=>"2", :users=>1},
        {:division_id=>"3", :users=>2},
        {:division_id=>"1", :users=>6},
        {:users => 11}
      )
    end
  end
end
