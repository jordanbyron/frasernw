class SeedPrivacyFaqs < ActiveRecord::Migration
  def up
    privacy_category = FaqCategory.where(name: "Privacy Compliance").first

    [{
      question: "What is Pathways used for?",
      answer: "The primary use of Pathways is to facilitate efficient, good quality patient referrals. In addition, Pathways includes the following information:\n\n* A range of approved resources, including but not limited to physician resources, patient information resources, community services, allied health supports, Pearls, calculators and forms\n\n* The results of division Shared Care work, typically geared to improving the efficiency and quality of referrals\n\n* Urgent clinical information that health care providers need to be aware of, e.g. disease outbreaks."
    },
    {
      question: "What privacy legislation, if any, is applicable to Pathways?",
      answer: "The Personal Information Protection Act (PIPA). This is because there is some personal information, as well as contact information, available to authorized users. Pathways does not contain patient information; therefore it does not fall under the Freedom of Information & Protection of Privacy Act (FIPPA)."
    },
    {
      question: "Who is authorized to use Pathways?",
      answer: "Authorized users are limited to:\n\n* All members of a division of family practice that is authorized to implement Pathways.  Typically division members are family practitioners, although in some cases divisions may also include Nurse Practitioners as members or associate members. In addition, locums, medical students & residents working in a division member’s office are also authorized to use Pathways during their period of employment.\n\n* Staff working in the offices of division members who use Pathways.\n\n* Specialists and clinics, and at each division’s discretion Nurse Practitioners and/or midwives.\n\n* The staff within the above practices/ clinics whose information is on Pathways.\n\n* Pathways Administrators and other division or provincial staff who support, or have a need to access Pathways, either on a permanent or temporary basis.\n\nIn summary, Pathways is for the use of the medical community who need to make or accept patient referrals. It is not available to the public."
    },
    {
      question: "How can I be sure that access to Pathways is limited to authorized users?",
      answer: "Access to Pathways is limited to verified, legitimate users who have been assigned a userid. Users determine their password, which must meet industry standards.\n\n Pathways has appropriate userid assignment & management policies and procedures in place and the Pathways Administrators have received training in their use."
    },
    {
      question: "What medical practice/ clinic information is collected?",
      answer: "The only medical practice/ clinic data that is collected is the information that is required to make effective, efficient referrals, as requested in authorized data collection survey forms. This includes a combination of the following public & personal information:\n\n* Office contact information\n\n* Hours of operation\n*Procedures done at the practice/ clinic\n\n* Referral information\n\n* Languages spoken in the office\n\n* Patient instructions\n\n* Cancellation policies\n\n* Clinic/ hospital associations"
    },
    {
      question: "How can I be sure that the information about my practice or clinic has been collected with my consent?",
      answer: "It is our policy to always ensure that medical practitioners are aware that by giving us their information it will be added to Pathways and to clarify how their information will used."
    },
    {
      question: "How is this information collected?",
      answer: "This information is collected and/or verified with the medical practice or clinic directly, via an authorized survey and accompanying letter outlining the purpose for which the information will be used, the fact that providing their information implies consent for it to be put on Pathways and who they can contact if they have questions or concerns. If required, data collection may also involve phone calls and/or personal office visits in order to ensure correct, complete practice/ clinic data has been collected."
    },
    {
      question: "What steps are taken to maintain the accuracy of the information about my practice or clinic?",
      answer: "Maintaining the accuracy of the practice or clinic information is a priority for Pathways and to that end a number of strategies are used. These include:\n\n* Upon initial data entry, providing each specialist or clinic with an access key and encouraging them to log onto Pathways, review their information and make any needed corrections.\n\n* Thereafter encouraging specialist/ clinics to regularly review their information. Approximately every 6 months each health care provider on Pathways is sent a link to their own information with a request that they update it as needed.\n\n* Encouraging Pathways users to send the Pathways Administrators information about practices/ clinics in their area and/or querying the accuracy of the information in Pathways. These notifications and queries are investigated with the practice or clinic and their information is updated accordingly."
    },
    {
      question: "How long will my information be retained?",
      answer: "The information will be retained as long as your practice or clinic is in operation or until you indicate that you no longer wish to have your practice or clinic information listed on Pathways. Upon your request, it will no longer be available to users and your information will be placed in a separate, secure database of removed data.\n\nMedical providers who retire or leave their practice, or practices/ clinics who close remain on Pathways for 2 years with very limited information identifying their current status. Thereafter their information is moved to the database containing removed data.\n\nAll removed data is automatically backed up for 1 year so that, if desired, a medical provider/ clinic can review the data that was previously displayed in Pathways. After 1 year the medical provider/ clinic’s data is permanently removed from all backups."
    },
    {
      question: "Where is this information stored?",
      answer: "Pathways information is currently stored on Heroku, which is a cloud based Platform-as-a-Service (PAAS).  Heroku is hosted using Amazon Web Services, which is located in the United States.\n\nThese providers have been selected because they are highly rated as a secure service providers and their security policies & practices are consistent with the Pathways security policy, the Pathways privacy policy, and with best practice industry standards."
    },
    {
      question: "What steps are taken to ensure that the personal information provided by medical providers and clinics is properly safeguarded?",
      answer: "All industry standard measures have been implemented. These include but are not limited to:\n\n* Clear identification of legitimate Pathways users\n\n* Use and management of Userids/ passwords\n\n* Strong database/ computer service security including the use of strong passwords and user identification technology, reviews of service provider privacy and security policies and practices, database redundancy and adherence to programming standards consistent with good security practices.\n\nIt has always been a priority for Pathways to maintain the trust of the medical community, in part by demonstrating compliance with good privacy and security practices."
    },
    {
      question: "If I have a question or complaint related to privacy or would like to confirm the accuracy and completeness of my information, who can I speak to?",
      answer: "You can contact the Pathways Privacy Officer:\n\n&nbsp;&nbsp;&nbsp;&nbsp;Mary Miller\n\n&nbsp;&nbsp;&nbsp;&nbsp;[Mary.Miller@FNWDivision.ca](mailto:Mary.Miller@FNWDivision.ca)"
    }].each_with_index do |faq, index|
      Faq.create(
        question: faq[:question],
        answer_markdown: faq[:answer],
        index: index + 1,
        faq_category_id: privacy_category.id
      )
    end
  end

  def down
    privacy_category = FaqCategory.where(name: "Privacy Compliance").first

    Faq.where(faq_category_id: privacy_category.id).destroy_all
  end
end
