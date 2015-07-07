module Archivable
  extend ActiveSupport::Concern

  module ClassMethods
    def active
      includes(:item).where(:archived => false)
    end

    def archived
      includes(:item).where(:archived => true)
    end
  end
end
