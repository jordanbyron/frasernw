require 'csv'

class CSV
  # takes array of arrays
  def self.write_from_array(file_path, array)
    CSV.open(file_path, "w+") do |csv|
      array.each do |row|
        csv << row
      end
    end
  end

  def self.write_to_string(array)
    CSV.generate do |csv|
      array.each do |row|
        csv << row
      end
    end
  end
end
