class PrepareUsageReport

  include ServiceObject.exec_with_args(:start_date, :end_date, :division, :user)

  def exec
    ## generate the report
    csv_string = CSV.write_to_string(
      UsageReport.exec(
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
      end_date: end_date
      division: division
    )
  end

  private

  def division
    @division ||= Division.where(id: division_id).first
  end

  def s3_object
    @s3_object ||= S3.bucket[object_key]
  end

  def object_key
    @key ||= generate_object_key
  end

  def generate_object_key
    key = "usage_report_#{SecureRandom.hex}"

    if s3_bucket[key].exists?
      generate_object_key
    else
      key
    end
  end
end
