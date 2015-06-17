# To help conditionalize by the type of editing for both clinic
# and specialist forms
#

class FormMetadata
  # Defined in controller
  def initialize(interaction_type)
  end

  secret_edit?
  admin_review?
  admin_rereview
  owner_edit?

end
