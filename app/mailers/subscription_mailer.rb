class SubscriptionMailer < ActionMailer::Base
  default from: "noreply@pathwaysbc.ca"

  def send_subscription_update(classification)
    #@subscription = subscription
    mail(:to => item.owners.map{|owner| owner.email}, :from => 'noreply@pathwaysbc.ca', :subject => "Pathways: Your WEEKLY/DAILY/MONTHLY Resource Update")
  end
end
