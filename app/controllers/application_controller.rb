class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    if request.xhr?
      raise exception
    else
      redirect_to root_path, :alert => "Access denied"
    end
  end

  before_filter :configure_permitted_parameters, if: :devise_controller?

  before_filter :closed

  protected
  def after_sign_in_path_for(user)
    params[:return_url].presence ||
      session["user_return_to"].presence ||
      root_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :name, :bitcoin_address, :current_password, :password, :password_confirmation])
  end

  def closed
    return if controller_name == "home" and action_name == "audit"

    render "layouts/closed", status: 404
  end
end
