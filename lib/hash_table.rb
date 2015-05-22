class HashTable
  attr_reader :rows

  # takes an array of hashes
  def initialize(rows)
    @rows = rows
  end

  def columns
    rows.inject([]) do |memo, row|
      memo | row.keys
    end
  end

  ################## DEPRECATED: use non-mutating function below
  def collapse_subsets!(uniq_function, base_accumulator, accumulator_function)
    subsets = rows.subsets &uniq_function

    # Construct the collapsed rows to put back into the table
    collapsed_rows = subsets.map do |set|
      accumulator = base_accumulator.dup

      set.inject(accumulator) do |accumulator, row|
        accumulator_function.call(accumulator, row)
      end
    end

    @rows = collapsed_rows
  end

  def collapse_subsets(uniq_function, base_accumulator, accumulator_function)
    subsets = rows.subsets &uniq_function

    # Construct the collapsed rows to put back into the table
    collapsed_rows = subsets.map do |set|
      accumulator = base_accumulator.dup

      set.inject(accumulator) do |accumulator, row|
        accumulator_function.call(accumulator, row)
      end
    end

    self.class.new(collapsed_rows)
  end

  def collapse_subset!(test, base_accumulator, accumulator_function)
    # Get the rows we want to collapse
    subset = rows.select {|row| test.call(row) }

    # Delete them from the table
    rows.reject! {|row| test.call(row) }

    # Build a collapsed row to put back into the table
    accumulator_row = subset.inject(base_accumulator) do |memo, row|
      accumulator_function.call(memo, row)
    end

    @rows = rows << accumulator_row
  end

  # for existing rows
  def transform_column!(column_key)
    rows.map do |row|
      row[column_key] = yield(row)
    end
  end

  # add column from a second table
  def add_column(options)
    new_table = self.clone
    options[:other_table].rows.each do |row|
      matched_row = new_table.rows.find do |inner_row|
        inner_row.match?(row, options[:keys_to_match])
      end

      if !matched_row.nil?
        matched_row[options[:new_column_key]] = row[options[:old_column_key]]
        # puts row
        # puts matched_row

        new_table
      else
        new_row = row.slice(*options[:keys_to_match]).merge(
          options[:new_column_key] => row[options[:old_column_key]]
        )

        new_table.add_row! new_row
      end
    end

    new_table
  end

  def self.sum_column(ary, column_key)
    ary.inject(0) do |memo, row|
      if !row[column_key].nil?
        memo += row[column_key].to_i
      else
        memo
      end
    end
  end

  def sum_column(column_key)
    rows.inject(0) do |memo, row|
      memo += row[column_key].to_i
    end
  end

  def add_rows(rows)
    HashTable.new(self.rows.clone + rows)
  end

  protected

  # mutates the object, so should not be public
  def add_row!(new_row)
    @rows << new_row
  end
end
