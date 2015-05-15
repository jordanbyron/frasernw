class Table
  attr_reader :rows

  # takes an array of hashes
  def initialize(rows)
    @rows = rows
  end

  def columns
    rows.inject([]) do |memo, row|
      memo | rows.keys
    end
  end

  def collapse_duplicate_rows!(uniq_function, base_accumulator, accumulator_function)
    # Get the duplicate rows
    dupe_sets = rows.dupe_sets uniq_function

    # Delete them from the table
    rows.delete_if  do |row|
      dupe_sets.flatten.include? row
    end

    # Construct the collapsed rows to put back into the table
    collapsed_rows = dupe_sets.map do |set|
      accumulator = base_accumulator.dup

      set.inject(accumulator) do |row|
        accumulator_function.call(accumulator, row)
      end
    end

    rows + collapsed_rows
  end

  def collapse_rows!(test, base_accumulator, accumulator_function)
    # Get the rows we want to collapse
    rows_to_collapse = rows.select test

    # Delete them from the table
    rows.delete_if {|row| rows_to_collapse.include? row }

    # Build a collapsed row to put back into the table
    rows_to_collapse.each do |row|
      accumulator_function.call(base_accumulator, row)
    end

    rows << accumulator_row
  end

  def transform_column!(column_key)
    rows.map do |row|
      row[column_key] = yield(row)
    end
  end

  def add_column!(key, default_value)
    rows.map! do |row|
      if block_given?
        row[key] = yield(row)
      else
        row[key] = default_value
      end
    end
  end
end
