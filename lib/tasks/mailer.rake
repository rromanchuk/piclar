namespace :mailer do
  task :send_daily_stats => :environment do
    Mailer.daily_stats.deliver
  end  
end
