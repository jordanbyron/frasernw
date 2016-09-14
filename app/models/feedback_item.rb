class FeedbackItem < ActiveRecord::Base
  include Noteable
  include Historical
  include PaperTrailable

  belongs_to :target, polymorphic: true

  belongs_to :user

  attr_accessible :feedback,
    :target_type,
    :target_id,
    :freeform_name,
    :freeform_email,
    :user_id,
    :user,
    :archiving_division_ids,
    :archived

  def self.specialist
    where(target_type: "Specialist")
  end

  def self.clinic
    where(target_type: "Clinic")
  end

  def self.content
    where(target_type: "ScItem")
  end

  def self.contact_us
    where("target_type = '' OR target_type IS NULL")
  end

  def self.active
    includes(:target).where(archived: false)
  end

  def self.archived
    includes(:target).where(archived: true)
  end

  def target_label
    if target
      target.label
    else
      "Deleted Item"
    end
  end

  def submitter_name
    if user.nil?
      freeform_name
    else
      user.name
    end
  end

  def submitter_email
    if user.nil?
      freeform_email
    else
      user.email
    end
  end

  def ownership_source
    if !target.nil?
      target
    elsif !user.nil?
      user
    else
      UnauthenticatedUser.new
    end
  end

  def owners
    ownership_source.owners
  end

  def owner_divisions
    ownership_source.owner_divisions
  end

  def contact_us?
    !target_type.present?
  end

  def targeted?
    target_type.present?
  end

  def label
    if contact_us?
      "'Contact Us' Feedback Item (##{id})"
    else
      "Feedback on '#{target_label}' (##{id})"
    end
  end

  def creator
    user || OpenStruct.new(name: freeform_name)
  end

  def version_archived
    @version_archived ||= versions.select do |version|
      version.changeset["archived"].present? &&
        version.changeset["archived"][0] == false &&
        version.changeset["archived"][1] == true
    end.last
  end

  def archived_by
    version_archived.present? ? version_archived.safe_user : UnknownUser.new
  end

  def active?
    !archived?
  end
end
