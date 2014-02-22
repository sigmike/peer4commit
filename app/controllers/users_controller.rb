class UsersController < ApplicationController

  before_action except: [:login, :index] do
    @user = User.where(id: params[:id]).first
    unless current_user && current_user == @user
      redirect_to root_path
    end
  end

  def show
  end

  def index
    @users = User.order(withdrawn_amount: :desc, commits_count: :desc).where('commits_count > 0').page(params[:page]).per(30)
  end

  def update
    if @user.update(users_params)
      redirect_to @user, notice: 'Your information saved!'
    else
      render :show, alert: 'Error updating peercoin address'
    end
  end

  def login
    @user = User.where(login_token: params[:token]).first
    if @user
      if params[:unsubscribe]
        @user.update unsubscribed: true
        flash[:alert] = 'You unsubscribed! Sorry for bothering you. Although, you still can leave us your peercoin address to get your tips.'
      end
      sign_in_and_redirect @user, event: :authentication
    else
      redirect_to root_url, alert: 'User not found'
    end
  end
 
  private
    def users_params
      params.require(:user).permit(:bitcoin_address)
    end
end
