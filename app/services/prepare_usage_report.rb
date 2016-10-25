class PrepareUsageReport < ServiceObject
  attribute :start_date
  attribute :end_date
  attribute :division_id
  attribute :user

  def call
    ## generate the report
    csv_string = CSV.write_to_string(
      CsvUsageReport.exec(
        start_date: start_date,
        end_date: end_date,
        division: Division.where(id: division_id).first
      )
    )

    ## upload it to s3

    s3_object.write(
      csv_string,
      acl: :private,
      expires: 1.day.from_now
    )

    ## email the link

    ReportsMailer.usage_report(
      start_date: start_date,
      end_date: end_date,
      division: division,
      user: user,
      object_key: object_key
    ).deliver
  end

  private

  def division
    @division ||= Division.where(id: division_id).first
  end

  def s3_object
    @s3_object ||= s3_bucket.objects[object_key]
  end

  def s3_bucket
    @s3_bucket ||= Pathways::S3.usage_reports_bucket
  end

  def object_key
    @key ||= generate_object_key
  end

  def generate_object_key
    key = "usage_report_#{SecureRandom.hex}"

    if s3_bucket.objects[key].exists?
      generate_object_key
    else
      key
    end
  end
end
