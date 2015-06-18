# Modify forms based on the type of interaction and current user

# @is_review == secret edit or automated_edit

class FormModifier
  include Rails.application.routes.url_helpers

  INTERACTION_TYPES = [
    :new,
    :edit,
    :review,
    :rereview,
    :review
  ]

  attr_reader :interaction_type, :current_user, :options

  # Defined in controller
  def initialize(interaction_type, current_user, options = {})
    if !INTERACTION_TYPES.include? interaction_type
      raise "invalid interaction type"
    end

    @interaction_type = interaction_type
    @current_user     = current_user
    @options          = options
  end

  def form_action
    if interaction_type == :new
      :create
    elsif interaction_type == :review
      :accept
    elsif secret_edit?
      :update
    elsif bot_edit?
      :temp_update
    else
      :update
    end
  end

  def method
    case interaction_type
    when :new then :post
    else :put
    end
  end

  # extract to metadata?
  def secret_edit?
    current_user.nil? && !bot_edit?
  end

  def bot_edit?
    current_user.nil? && options[:bot] == true
  end

  def owner_edit?
    current_user.present? && !current_user.admin? && interaction_type == :edit
  end

  # somewhat unintuitively, we give clinic/specialist owners the token edit endpoint
  def token_edit?
    owner_edit? || secret_edit? || bot_edit?
  end

  def admin?
    current_user.present? && current_user.admin?
  end

  def admin_rereview?
    admin? && interaction_type == :rereview
  end

  def admin_review?
    admin? && interaction_type == :review
  end

  def new_record?
    interaction_type == :new
  end

  def divisions
    if current_user.present?
      current_user.divisions
    else
      Division.all
    end
  end

  # we don't want regular users to be able to edit all the fields directly
  def restrict_editing?
    secret_edit? || owner_edit?
  end

  # instead, we'll give them generic comment boxes, which the admins can use to update the records later
  def show_comment_boxes?
    secret_edit? || owner_edit? || admin_review? || admin_rereview?
  end
end
