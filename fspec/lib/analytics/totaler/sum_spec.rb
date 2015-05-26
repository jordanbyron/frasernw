require 'lib/hash_table'
require 'lib/analytics/reducer/user'

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
    it "should return the data collapsed by user id" do
      reducer = Analytics::Reducer::User.new(
        sample_table,
        dimensions: [ :user_type_key, :division_id ]
      )

    end
  end
end
