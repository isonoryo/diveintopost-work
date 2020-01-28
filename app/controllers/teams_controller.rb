class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy owner_change]
  before_action :correct_user_is_owner?, only:[:edit, :update]

  def index
    @teams = Team.all
  end

  def show
    @working_team = @team
    change_keep_team(current_user, @team)
  end

  def new
    @team = Team.new
  end

  def edit; end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: I18n.t('views.messages.create_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :new
    end
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: I18n.t('views.messages.update_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :edit
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: I18n.t('views.messages.delete_team')
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  def isOwned?(user)
    return false if user.nil?
    return self.user_id == user.id
  end

  def owner_change
    @user = User.find_by(id: params[:owner_change_user_id])
    if @team.update(owner: @user)
      OwnerChangeMailer.owner_change_mail(@user.email).deliver
      redirect_to team_url, notice: 'オーナー権限を移動しました。'
    else
      redirect_to team_url, notice: 'オーナー権限は移動できません。'
    end
  end

  private

  def correct_user_is_owner?
    if @team.owner.id != current_user.id
      redirect_to team_url
      flash[:notice] = "オーナー以外に編集権限はありません"
    end
  end

  def set_team
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end
end
