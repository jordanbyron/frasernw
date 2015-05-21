require 'csv'

class CSV
  # takes array of arrays
  def self.write_from_array(file_path, array)
    CSV.open(file_path, "w+") do |csv|
      array.each do |row|
        puts row
        csv << row
      end
    end
  end
end
