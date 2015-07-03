class Faq < ActiveRecord::Base
  attr_accessible :question, :answer_markdown, :index, :faq_category_id

  belongs_to :faq_category

  def category_name
    faq_category.name
  end

end
