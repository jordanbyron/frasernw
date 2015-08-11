class DivisionDisplayScItem < ActiveRecord::Base
  belongs_to :division
  belongs_to :sc_item

  include PaperTrailable

end
