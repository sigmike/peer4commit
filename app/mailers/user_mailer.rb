class UserMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  
  def new_tip user, tip
    @user = user
    @tip  = tip

    mail to: user.email, subject: "You received a tip for your commit"
  end

  def security_issue(user)
    @user = user
    mail to: user.email, subject: "Security issue on peer4commit.com"
  end
end
