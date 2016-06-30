class ScItemMailing < ActiveRecord::Base
  belongs_to :sc_item
  belongs_to :user
end
