# Base search data that is used regardless of whether
# User is searching divisionally or with the expanded area

class GlobalSearchData

  CACHE_KEY = "global_search_data"

  def data
    cached
  end

  def regenerate_cache
    Rails.cache.delete CACHE_KEY

    data
  end

  def cached
    Rails.cache.fetch CACHE_KEY do
      generate
    end
  end

  def generate
    search_data = Array.new

    Specialization.not_in_progress_for_divisions(Division.all).uniq.each do |specialization|

      entry = {
        "n" => specialization.name,
        'id' => specialization.id,
        "go" => order_map["Specializations"] }
      search_data << entry
    end

    ScCategory.searchable.each do |category|
      entry = {
        "n" => category.full_name,
        'id' => category.id,
        "go" => order_map["Content"] }
      search_data << entry
    end

    Procedure.includes(:procedure_specializations => :specialization).each do |procedure|

      #this handles those that only belong to specializations that are "in progress", as well as orphaned entities
      next if procedure.procedure_specializations.reject{ |ps| ps.specialization.fully_in_progress }.length == 0

      entry = {
        "n" => procedure.full_name,
        "sp" => procedure.procedure_specializations.reject{ |ps| ps.specialization.fully_in_progress }.collect{ |ps| ps.specialization_id },
        "id" => procedure.id,
        "go" => order_map["Procedures"] }
      search_data << entry
    end

    Language.all.each do |language|
      entry = {
        "n" => language.name,
        "id" => language.id,
        "go" => order_map["Languages"] }
      search_data << entry
    end

    Hospital.all.each do |hospital|
      entry = {
        "n" => hospital.name,
        "c" => hospital.city.present? ? hospital.city.id : "",
        "id" => hospital.id,
        "go" => order_map["Hospitals"] }
      search_data << entry
    end

    search_data
  end
end
