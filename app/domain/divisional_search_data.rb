class DivisionalSearchData
  attr_reader :division

  def initialize(division)
    @division = division
  end
  delegate :entries, :content, to: :cache

  def regenerate_cache
    cache.regenerate
  end

  def generator
    @generator ||= DivisionalSearchDataGenerator.new(division)
  end

  private

  def cache
    @cache ||= DivisionalSearchDataCache.new(division)
  end
end
