class SeedHelpFaqs < ActiveRecord::Migration
  def up
    help_category = FaqCategory.where(name: "Help").first

    [{
      question: "I see some information that is wrong or out-of-date for a specialist or clinic. What can I do?",
      answer: "At the bottom of each specialist or clinic page is a button labelled **Incorrect Information? Let us know.**  If you press this button, a form will appear that will allow you to ender any comments about the specialist or clinic that you have. Type your feedback, and press \"Send Feedback\". Your comments will be sent directly to your administration team, who will review and act on them, possibly getting in touch with you for follow up.\n\nWe encourage all users to send feedback any time they see something they think is incorrect; Pathways is built on the concept of local ownership, and your feedback helps keep the site accurate for everyone."
    },
    {
      question: "What are Favourites and how do I use them?",
      answer: "A favourite is a quick shortcut to a specialist or clinic, one that you or your office regularly references.\n\nYou can make a favourite by pressing the <i class='icon-text icon-heart'></i> on the specialist or clinic page beside their name. It will change to a <i class='icon-red icon-heart'></i> and is now in your Favourites list, which is accessible from the top of every page, under **Favourites**.\n\nSimilarly, you can remove a favourite at any time by clicking on the red heart, which will change back to black. You can also favourite content that you regularly reference, such as Red Flags or Pearls."
    },
    {
      question: "What can I type into the search box?",
      answer: "The search box accepts the name of any **specialty, specialist, clinic, area of practice, hospital, clinic, or GP resource** - anything that exists on Pathways.\n\nYou don't have to spell what you are looking for correctly nor completely; results will start to match as you type.  We think you will find it a very fast way to navigate Pathways."
    },
    {
      question: "How can I change the email or password we use to log in?",
      answer: "From the **You** menu at the top of each page you are able to change the e-mail and password associated with your account. Note that changing either will log you out, and ask you to log back in with your new settings."
    },
    {
      question: "How can I use or share the information on Pathways?",
      answer: "Please see the [Terms of Use](/terms_and_conditions) for details."
    },
    {
      question: "I have a question or comment not addressed here.  Who can I contact?",
      answer: "Please send us an email at [administration@pathwaysbc.ca](mailto:administration@pathwaysbc.ca) and we will get back to you as soon as possible."
    }].each_with_index do |faq, index|
      Faq.create(
        question: faq[:question],
        answer_markdown: faq[:answer],
        index: index + 1,
        faq_category_id: help_category.id
      )
    end
  end

  def down
    help_category = FaqCategory.where(name: "Help").first

    help_category.faqs.destroy_all
  end
end
