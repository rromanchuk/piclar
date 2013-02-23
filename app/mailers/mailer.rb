class Mailer < ActionMailer::Base
  default from: 'noreply@piclar.com'

  def daily_stats
    @total_users = User.count
    @total_users_yesterday = User.added_yesterday.count
    mail to: 'stats@piclar.com', subject: 'Piclar Stats'
  end

  private

  def admins_emails
    User.admin.pluck :email
  end
end
