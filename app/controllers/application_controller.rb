class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def load_project
    @project = Project.where(id: params[:id]).first
    unless @project
      redirect_to root_path, alert: "Project not found"
    end
  end
end
