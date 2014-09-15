class Subscription < ActiveRecord::Base
	belongs_to :user

  has_many :subscription_divisions, dependent: :destroy
	has_many :divisions, through: :subscription_divisions

	has_many :news_items, through: :divisions
	has_many :sc_categories, through: :divisions


	has_many :subscription_specializations, dependent: :destroy
	has_many :specializations, through: :subscription_specializations

end
