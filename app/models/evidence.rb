class Evidence < ActiveRecord::Base
  include PaperTrailable
  include Historical
  include Noteable

  attr_accessible :description, :level

  validates :level, presence: true

  has_many :sc_items

  def label # needed for Historical
    return "#{level}: #{description}" if description.present?
    return level
  end
end
