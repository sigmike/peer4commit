require 'net/http'

class ProjectsController < ApplicationController
  def index
    @projects = Project.order(available_amount_cache: :desc, watchers_count: :desc, full_name: :asc).page(params[:page]).per(30)
  end

  def show
    @project = Project.find params[:id]
    if @project and @project.bitcoin_address.nil? and (github_id = @project.github_id).present?
      label = "#{github_id}@peer4commit"
      address = PeercoinDaemon.instance.get_new_address(label)
      @project.update_attributes(bitcoin_address: address, address_label: label)
    end
  end

  def edit
    @project = Project.find params[:id]
    authorize! :update, @project
  end

  def update
    @project = Project.find params[:id]
    authorize! :update, @project
    @project.attributes = project_params
    if @project.tipping_policies_text.try(:text_changed?)
      @project.tipping_policies_text.user = current_user
    end
    if @project.save
      redirect_to project_path(@project), notice: "The project settings have been updated"
    else
      render 'edit'
    end
  end

  def decide_tip_amounts
    @project = Project.find params[:id]
    authorize! :decide_tip_amounts, @project
    if request.patch?
      @project.available_amount # preload anything required to get the amount, otherwise it's loaded during the assignation and there are undesirable consequences
      @project.attributes = params.require(:project).permit(tips_attributes: [:id, :amount_percentage])
      if @project.save
        message = "The tip amounts have been defined"
        if @project.has_undecided_tips?
          redirect_to decide_tip_amounts_project_path(@project), notice: message
        else
          redirect_to @project, notice: message
        end
      end
    end
  end

  def qrcode
    @project = Project.find params[:id]
    respond_to do |format|
      format.svg  { render :qrcode => @project.bitcoin_address, level: :l, unit: 4 }
    end
  end

  def create
    project_name = params[:full_name].
      gsub(/https?\:\/\/github.com\//, '').
      gsub(/\#.+$/, '').
      gsub(' ', '')
    client = Octokit::Client.new \
      :client_id     => CONFIG['github']['key'],
      :client_secret => CONFIG['github']['secret']
    begin
      repo = client.repo project_name
      @project = Project.find_or_create_by full_name: repo.full_name
      @project.update_github_info repo
      redirect_to @project
    rescue Octokit::NotFound
      redirect_to projects_path, alert: "Project not found"
    end
  end

  private
  def project_params
    params.require(:project).permit(:hold_tips, tipping_policies_text_attributes: [:text])
  end
end
