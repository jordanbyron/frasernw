class DivisionalSearchDataGenerator
  attr_reader :division

  def initialize(division)
    @division = division
  end

  def entries
    GenerateSearchData::Entries.new(division).exec
  end

  def content
    GenerateSearchData::Content.new(division).exec
  end
end
