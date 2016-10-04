class ReviewItemsMailer < ActionMailer::Base
  include ApplicationHelper

  def user_edited(review_item)
    @review_item = review_item
    @verb = @review_item.no_updates? ? "confirmed as accurate" : "edited"
    @whodunnit = begin
      if @review_item.secret_edit?
        "using a secret edit link"
      else
        "by #{@review_item.editor.name}"
      end
    end

    item = review_item.item
    mail(
      to: item.owners.map(&:email),
      from: 'noreply@pathwaysbc.ca',
      subject: "Pathways: #{item.name} has had been edited and is in the review queue"
    )
  end

end
