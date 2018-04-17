class Api::V1::MattermostController < Api::ApplicationController
  require_dependency 'commands'

  skip_before_action :login_by_basic_auth
  before_action :authenticate_mattermost

  def where
    render json: Commands::Where.new(command_params).response
  end

  def where_is
    render json: Commands::WhereIs.new(command_params).response
  end

  private

  def authenticate_mattermost
    head :unauthorized unless params[:team_id] && params[:team_domain] &&
      ActiveSupport::SecurityUtils.secure_compare(
        params[:team_id], ENV['MATTERMOST_TEAM_ID']
      ) &&
      ActiveSupport::SecurityUtils.secure_compare(
        params[:team_domain], ENV['MATTERMOST_DOMAIN']
      ) &&
      ENV['MATTERMOST_IPS'].split.include?(request.remote_ip)
  end

  def command_params
    params.permit(:user_name, :text, :token)
  end
end
