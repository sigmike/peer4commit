require 'net/http'

class ProjectsController < ApplicationController

  before_action :load_project, only: [:qrcode, :edit, :update, :decide_tip_amounts]

  load_and_authorize_resource only: [:commit_suggestions, :donate, :donors]

  def index
    @projects = Project.enabled.order(available_amount_cache: :desc, watchers_count: :desc, full_name: :asc).page(params[:page]).per(30)
  end

  def show
    @project = Project.where(id: params[:id]).first
    unless @project
      redirect_to root_path, alert: "Project not found"
      return
    end
    commontator_thread_show(@project)

    load_github_repo
    update_project_avatar_url
  end

  def new
    unless user_signed_in?
      redirect_to new_user_session_path(return_url: request.original_url), flash: {info: "You must be logged in to create a new project"}
      return
    end
    @project = Project.new(params[:project])
  end

  def edit
    authorize! :update, @project
  end

  def update
    authorize! :update, @project
    @project.attributes = project_params
    if @project.tipping_policies_text.try(:text_changed?)
      @project.tipping_policies_text.user = current_user
    end
    if @project.save
      redirect_to project_path(@project), notice: "The project has been updated"
    else
      render 'edit'
    end
  end

  def decide_tip_amounts
    authorize! :decide_tip_amounts, @project
    if request.patch?
      @project.attributes = params.require(:project).permit(tips_attributes: [:id, :decided_amount_percentage, :decided_free_amount])
      @project.tips.each do |tip|
        next if tip.decided?
        if tip.decided_amount_percentage.present?
          tip.amount = @project.available_amount * (tip.decided_amount_percentage.to_f / 100)
        elsif tip.decided_free_amount.present?
          tip.amount = tip.decided_free_amount.to_d * COIN
        end
      end
      if @project.available_amount < 0
        flash.now[:error] = "The project has insufficient funds"
        return
      end
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
    respond_to do |format|
      format.svg  { render qrcode: @project.bitcoin_address, level: :l, unit: 4 }
    end
  end

  def create
    @project = Project.new(project_params)
    @project.hold_tips = true
    @project.collaborators.build(user: current_user)
    authorize! :create, @project

    if @project.save
      redirect_to @project, notice: "The project was created"
    else
      render "new"
    end
  end

  def commit_suggestions
    respond_to do |format|
      format.json do
        query = params[:query]
        commits = @project.commits.where('sha LIKE ? OR username LIKE ? OR message LIKE ?', "#{query}%", "%#{query}%", "%#{query}%")
        commits = commits.map do |commit|
          {
            sha: commit.sha,
            description: [
              commit.sha[0,10],
              commit.username.present? ? "@#{commit.username}" : nil,
              ERB::Util.html_escape(commit.message).truncate(30),
            ].reject(&:blank?).join(" "),
          }
        end
        render json: commits
      end
    end
  end

  def github_user_suggestions
    respond_to do |format|
      format.json do
        query = params[:query]
        users = User.enabled.where.not(nickname: nil).where.not(nickname: '').where('nickname LIKE ? OR name LIKE ?', "%#{query}%", "%#{query}%")
        users = users.map do |user|
          {
            login: user.nickname,
            description: [
              user.nickname,
              user.name.present? ? "(#{user.name})" : nil,
            ].reject(&:blank?).join(" "),
          }
        end
        render json: users
      end
    end
  end

  def donate
    if params[:donation_address]
      sender_address = params[:donation_address][:sender_address].strip
      @donation_address = @project.donation_addresses.where(sender_address: sender_address).first_or_create
    else
      @donation_address = @project.donation_addresses.build
    end
  end

  private
  def project_params
    params.require(:project).permit(:name, :description, :detailed_description, :full_name, :auto_tip_commits, :hold_tips, tipping_policies_text_attributes: [:text])
  end

  def load_project
    @project = Project.enabled.where(id: params[:id]).first
    unless @project
      redirect_to root_path, alert: "Project not found"
    end
  end

  def load_github_repo
    return if @project.nil?

    github_repo_uri  = URI "#{GITHUBAPI_REPO_URL}/#{@project.full_name}"
    github_repo_resp = Net::HTTP.get_response github_repo_uri
    return unless github_repo_resp.is_a? Net::HTTPSuccess

    github_repo_json = JSON.parse github_repo_resp.body
    return if github_repo_json["id"].nil?

    @github_repo     = github_repo_json
    @github_owner    = @github_repo["owner"]
    @github_org      = @github_repo["organization"]
    @is_organization = @github_org.present?
  end

  def update_project_avatar_url
    return if @project.nil? || !@is_organization

    avatar_url   = @github_org["avatar_url"]
    is_unchanged = avatar_url.eql? @project.avatar_url

    @project.update_attribute :avatar_url , avatar_url unless is_unchanged
  end
end
