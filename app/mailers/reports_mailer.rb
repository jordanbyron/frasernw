class ReportsMailer < ActionMailer::Base
  include ApplicationHelper

  def usage_report(args)
    @args = args

    mail(
      to: args[:user].email,
      from: 'noreply@pathwaysbc.ca',
      subject: "Pathways: Link To Your Usage Report"
    )
  end
end
