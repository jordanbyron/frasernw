class DivisionUser < ActiveRecord::Base
  belongs_to :division
  belongs_to :user

  include PaperTrailable
end
