module Sectorable
  extend ActiveSupport::Concern

  SECTORS = [
    :public,
    :private
  ]

  included do
    attr_accessible *SECTORS
  end

  def no_sectors?
    SECTORS.none? do |sector|
      send(sector)
    end
  end

  def sector
    sector_annotations = {
      public: " (MSP billed)",
      private: " (Patient pays)"
    }

    return "Didn't answer" unless sector_info_available?

    SECTORS.
      select{|sector| self.send(sector) }.
      map{|sector| "#{sector.capitalize}#{sector_annotations[sector]}" }.
      to_sentence
  end

  def sector_info_available?
    SECTORS.any? do |sector|
      send(sector).is_a?(TrueClass)
    end
  end
end
