every 1.day, at: '8:00 am' do
  rake 'mailer:send_daily_stats', :environment => :production
end