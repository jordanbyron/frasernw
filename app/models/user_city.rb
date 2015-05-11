class UserCity < ActiveRecord::Base
  belongs_to :user
  belongs_to :city

  has_many :user_city_specializations, :dependent => :destroy
  has_many :specializations, :through => :user_city_specializations

  has_paper_trail
end
