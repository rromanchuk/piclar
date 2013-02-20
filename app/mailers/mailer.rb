class Mailer < ActionMailer::Base
  default from: 'noreply@piclar.com'

  def daily_email
   

    mail to: admins_emails, subject: 'Linksie Daily'
  end

  private

  def admins_emails
    User.admin.pluck :email
  end
end
