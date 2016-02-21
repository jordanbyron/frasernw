class Evidence < ActiveRecord::Base
  include PaperTrailable
  include Historical
  include Noteable

  attr_accessible :definition, :level, :quality_of_evidence

  validates :level, presence: true

  has_many :sc_items

  def label # needed for Historical
    "(LOE=#{level})"
  end

  def definition_as_html
    BlueCloth.new(definition).to_html.html_safe
  end
end
