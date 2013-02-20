namespace :mailer do
  task :send_daily_linksie_stats => :environment do
    Mailer.daily_linksie_stats.deliver
  end  
end
