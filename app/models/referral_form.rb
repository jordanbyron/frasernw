class ReferralForm < ActiveRecord::Base
  include Noteable
  include ActionView::Helpers::TextHelper

  belongs_to :referrable, :polymorphic => true

  has_attached_file :form,
    :storage => :s3,
    :bucket => ENV['S3_BUCKET_NAME'],
    :s3_credentials => {
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }

  has_paper_trail

  def label
    "#{referrable.name} (Referral Form)"
  end

  def in_divisions(divisions)
    referrable.present? && (referrable.divisions & divisions).present?
  end

end
