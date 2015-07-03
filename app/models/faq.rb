class Faq < ActiveRecord::Base
  attr_accessible :question, :answer_markdown, :index, :faq_category_id

  belongs_to :faq_category

end
