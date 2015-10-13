class DivisionCity < ActiveRecord::Base
  belongs_to :division
  belongs_to :city

  include PaperTrailable

end
