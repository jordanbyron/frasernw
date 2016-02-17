class UserMask < ActiveRecord::Base
  include HasRole

  attr_accessible :role,
    :division_ids,
    :user_id

  belongs_to :user

  has_many :user_mask_divisions, dependent: :destroy
  has_many :divisions, through: :user_mask_divisions

end
