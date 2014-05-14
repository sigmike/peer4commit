class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    # render text: "#{request.env["omniauth.auth"].to_json}"
    info = request.env["omniauth.auth"]["info"]
    @user = User.find_by(nickname: info["nickname"])
    if @user.nil? and info["verified_emails"].any?
      @user = User.find_by(email: info["verified_emails"])
    end
    unless @user
      if info['primary_email']
        generated_password = Devise.friendly_token.first(8)
        @user = User.create!(
          email: info['primary_email'],
          password: generated_password,
          nickname: info['nickname']
        )
      else
        set_flash_message(:error, :failure, kind: 'GitHub', reason: 'your primary email address should be verified.')
        redirect_to new_user_session_path and return
      end
    end

    @user.name = info['name']
    @user.image = info['image']
    @user.save

    sign_in_and_redirect @user, event: :authentication
    set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?
  end
end
