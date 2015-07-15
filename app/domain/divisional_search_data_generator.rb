class DivisionalSearchDataGenerator
  attr_reader :division

  def initialize(division)
    @division = division
  end

  def entries
    GenerateSearchData::Entries.new(self).exec
  end

  def content
    GenerateSearchData::Content.new(self).exec
  end
end
