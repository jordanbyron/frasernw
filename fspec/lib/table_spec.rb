require 'lib/hash_table.rb'
require 'config/initializers/ruby_extensions/hash.rb'

describe HashTable do
  let(:sample_data) do
    [
      { user_type: 1, division: 2, jan: 3 },
      { user_type: 10, division: 11, jan: 12 }
    ]
  end
  let(:table) { HashTable.new(sample_data) }

  let(:sample_data_2) do
    [
      { user_type: 1, division: 2, views: 3 },
      { user_type: 10, division: 11, views: 12 }
    ]
  end
  let(:table_2) { HashTable.new(sample_data_2) }

  describe "#add_column" do
    it "adds a new column with the name provided" do
      new_table = table.add_column(
        other_table: table_2,
        keys_to_match: [:user_type, :division],
        old_column_key: :views,
        new_column_key: :feb
      )
      new_table.columns.should include(:feb)
    end

    it "assigns the appropriate value to that column" do
      new_table = table.add_column(
        other_table: table_2,
        keys_to_match: [:user_type, :division],
        old_column_key: :views,
        new_column_key: :feb
      )
      new_table.rows.first[:feb].should == 3
    end
  end
end
