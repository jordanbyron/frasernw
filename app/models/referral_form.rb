class ReferralForm < ActiveRecord::Base
  include Noteable
  include Historical
  include PaperTrailable

  include ActionView::Helpers::TextHelper

  belongs_to :referrable, polymorphic: true

  attr_accessible :description, :form

  has_attached_file :form,
    storage: :s3,
    s3_protocol: :https,
    bucket: Pathways::S3.switchable_bucket_name(:referral_forms),
    s3_credentials: {
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    }
  validates_attachment_content_type :form,
    content_type: [
      /\Aimage\/.*\Z/,
      "application/pdf",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    ]

  def label
    "#{referrable.name} (Referral Form)"
  end

  def in_divisions(divisions)
    referrable.present? && (referrable.divisions & divisions).present?
  end

  def file_format
    case form_content_type
    when "application/pdf"
      "PDF"
    when "application/vnd.openxmlformats-officedocument.wordprocessingml."\
        "document"
      "DOCX"
    else
      "image"
    end
  end

end
