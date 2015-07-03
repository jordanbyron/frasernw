class FaqCategory < ActiveRecord::Base
  has_many :faqs, dependent: :destroy

  def self.help
    where(name: "Help").first
  end

  def sorted_by_index
    faqs.order(:index)
  end

  def next_available_index
    sorted_by_index.last.index + 1
  end
end
