task :send_security_issue => :environment do
  User.where(unsubscribed: nil).each do |user|
    UserMailer.security_issue(user).deliver
  end
end
