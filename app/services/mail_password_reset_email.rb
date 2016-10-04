class MailPasswordResetEmail < ServiceObject
  attribute :user_id

  def call
    PasswordResetMailer.password_reset_instructions(User.find(user_id)).deliver
  end
end
