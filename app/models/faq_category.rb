class FaqCategory < ActiveRecord::Base
  has_many :faqs, dependent: :destroy

  def self.help
    where(name: "Help").first
  end

  def sorted_by_index
    faqs.order(:index)
  end
end
