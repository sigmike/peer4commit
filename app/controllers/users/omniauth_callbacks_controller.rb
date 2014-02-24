class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :load_omniauth_info, only: :github

  def github
    @user = User.find_by(nickname: @omniauth_info.nickname) ||
            User.find_by(email: @omniauth_info.email) ||
            User.create_with_omniauth!(@omniauth_info)

    @user.update(@omniauth_info.slice(:name, :image).as_json)
    
    sign_in_and_redirect @user, event: :authentication
    set_flash_message(:notice, :success, kind: 'Github') if is_navigational_format?
  end

  private

  def load_omniauth_info
    @omniauth_info = request.env['omniauth.auth']['info']
    unless @omniauth_info
      set_flash_message(:error, :failure, kind: 'Github', reason: 'we were unable to fetch your information.')
      redirect_to users_login_path and return
    end
  end
end
