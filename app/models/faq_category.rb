class FaqCategory < ActiveRecord::Base
  has_many :faqs, dependent: :destroy


end
