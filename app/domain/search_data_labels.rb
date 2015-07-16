module SearchDataLabels

  GenerateSearchDataLabels.generators.each do |label_type, generator|
    define_method label_type do
      cached(label_type)
    end
  end

  def regenerate_caches
    GenerateSearchDataLabels.generators.each do |label_type, generator|
      invalidate_cache_for label_type

      self.send label_type
    end
  end

  def cached(label_type)
    Rails.cache.fetch cache_key(label_type) do
      generate(label_type)
    end
  end

  def generate(label_type)
    GenerateSearchDataLabels.generators(method).call
  end

  def invalidate_cache_for(label_type)
    Rails.cache.delete cache_key(label_type)
  end

  def cache_key(label_type)
    "search_data_labels/#{label_type}"
  end

end
