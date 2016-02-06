class Evidence < ActiveRecord::Base
  include PaperTrailable
  include Historical
  include Noteable

  attr_accessible :summary, :level

  validates :level, presence: true

  has_many :sc_items

  def label # needed for Historical
    return "#{level}: #{summary}" if summary.present?
    return level
  end
end
