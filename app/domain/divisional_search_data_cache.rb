class DivisionalSearchDataCache
  attr_reader :division

  def initialize(division)
    @division = division
  end

  def regenerate
    flush

    entries
    content

    true
  end

  def entries
    Rails.cache.fetch(entries_key) do
      generator.entries
    end
  end

  def content
    Rails.cache.fetch(content_key) do
      generator.content
    end
  end

  private

  def generator
    @generator ||= division.search_data.generator
  end

  def flush
    Rails.cache.delete(entries_key)
    Rails.cache.delete(content_key)
  end

  def entries_key
    "divisional_entries_search_data_#{division.id}"
  end

  def content_key
    "divisional_content_search_data_#{division.id}"
  end
end
