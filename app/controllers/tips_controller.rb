class TipsController < ApplicationController

  before_action :load_project

  def index
    if params[:project_id]
      @tips = @project.tips.includes(:user).order(created_at: :desc).page(params[:page]).per(30)
    else
      @tips = Tip.includes(:user, :project).order(created_at: :desc).page(params[:page]).per(30)
    end
  end
end