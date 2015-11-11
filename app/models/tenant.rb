class Tenant < ActiveRecord::Base
  attr_accessible :subdomain, :title
end
