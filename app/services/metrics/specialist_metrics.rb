module Metrics
  class SpecialistMetrics

  # def self.all_by_specialty
  #   # can't get this working
  #   # self.joins([:specialist_specializations => :specialization]).order('specialists, specializations.name ASC').all.map{|s| s.specializations.first.name}
  # end

  attr_accessor :table

  def initialize(*args)
    options = args.extract_options!
    # options[] defines which table columns to use.
    # (all: true) uses all tables
    table = []
    Specialist.includes([:specializations, :favorites, :versions, :archived_feedback_items, :feedback_items]).all.each do |specialist|
      specialist_row = Hash.new
      specialist_row[:favorites]            =   specialist.favorites.count                           if ((options[:all] || options[:favorites])            == true)
      specialist_row[:specialist_id]        =   specialist.id                                        if (options[:all] || options[:id])                   == true
      specialist_row[:name]                 =   specialist.name                                      if (options[:all] || options[:favorites])            == true
      specialist_row[:specialty]            =   specialist.specializations.map{|s| s.name}.join(",") if (options[:all] || options[:specialty])            == true
      specialist_row[:specialty_count]      =   specialist.specialist_specializations.count          if (options[:all] || options[:specialty_count])      == true
      specialist_row[:division]             =   specialist.divisions.map { |d| d.name  }.join(",")   if (options[:all] || options[:division])             == true
      specialist_row[:division_count]       =   specialist.divisions.count                           if (options[:all] || options[:division_count])       == true
      specialist_row[:first_version]        =   specialist.versions.last.created_at                  if (options[:all] || options[:first_version])        == true
      specialist_row[:last_version]         =   specialist.versions.first.created_at                 if (options[:all] || options[:last_version])         == true
      specialist_row[:version_number]       =   specialist.versions.count                            if (options[:all] || options[:version_number])       == true
      specialist_row[:feedback_items]       = ( specialist.feedback_items +
                                                specialist.archived_feedback_items).
                                                map { |f| f.feedback  }.join("  <<<<<<<>>>>>>>  ")   if (options[:all] || options[:version_number])       == true
      specialist_row[:feedback_items_count] = ( 0 + specialist.feedback_items.count +
                                                specialist.archived_feedback_items.count)            if (options[:all] || options[:feedback_items_count]) == true
      table << specialist_row
    end
    @table = table
  end

  def as_csv
    CSVReport::ConvertHashArray.new(self).exec
  end


  # table = Array.new

  # Clinic.includes([:specializations, :versions, :archived_feedback_items, :feedback_items]).all.each do |clinic|

  #   clinic_row = Hash.new
  #   clinic_row[:id] = clinic.id
  #   clinic_row[:name] = clinic.name
  #   clinic_row[:specialty] = clinic.specializations.select(:name)
  #   clinic_row[:division] = clinic.divisions.map { |d| d.name  }
  #   clinic_row[:first_version] = clinic.versions.last.created_at
  #   clinic_row[:last_version] = clinic.versions.first.created_at
  #   clinic_row[:version_number] = clinic.versions.count

  #   clinic_row[:feedback_items] = clinic.archived_feedback_items + clinic.feedback_items
  #   clinic_row[:feedback_item_count] = (0 + clinic.archived_feedback_items.count + clinic.feedback_items.count)

  #   table << clinic_row
  # end

end
end