class AgendasController < ApplicationController
  before_action :set_agenda, only: %i[show edit update destroy]

  def index
    @agendas = Agenda.all
  end

  def new
    @team = Team.friendly.find(params[:team_id])
    @agenda = Agenda.new
  end

  def create
    @agenda = current_user.agendas.build(title: params[:title])
    @agenda.team = Team.friendly.find(params[:team_id])
    current_user.keep_team_id = @agenda.team.id
    if current_user.save && @agenda.save
      redirect_to dashboard_url, notice: I18n.t('views.messages.create_agenda')
    else
      render :new
    end
  end

  def destroy
    @team = Team.find_by(id: @agenda.team_id)
    if (@agenda.user_id != current_user.id) || (@team.owner_id != current_user.id)
      redirect_to team_agendas_path(@agenda.team_id), notice: "権限がありません"
    else
      @agenda.destroy
      @team.assign_users.each do |user|
          AgendaDestroyMailer.agenda_destroy_mail(user.email).deliver
        end
        redirect_to dashboard_path, notice: "アジェンダを削除しました。"
    end
  end

  private

  def set_agenda
    @agenda = Agenda.find(params[:id])
  end

  def agenda_params
    params.fetch(:agenda, {}).permit %i[title description]
  end
end
