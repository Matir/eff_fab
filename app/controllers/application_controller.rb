class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :login_by_basic_auth
  before_action :set_raven_context
  before_action :set_hero

  def admin_only
    unless current_user.try(:admin?) || current_user.try(:admin_user_mode?)
      redirect_to '/', :alert => "Access denied."
    end
  end

  def author_access_only
    redirect_to '/', :alert => "Access denied." if current_user != @user
  end

  def login_by_basic_auth
    if ActionController::HttpAuthentication::Basic::has_basic_credentials?(request)
      name = ActionController::HttpAuthentication::Basic::user_name_and_password(request)[0]
      user = User.where(email: name + "@eff.org")[0]
      sign_in :user, user if user
    end
  end

  private

  def set_hero
    @hero_text = "What are your coworkers up to this week?"
    @hero_title = "Forward & Back"
    @hero_image = ActionController::Base.helpers.asset_path('forward-text-white.svg')
  end

  def set_raven_context
    return unless Rails.env.production?
    if current_user
      Raven.user_context(id: current_user.id, email: current_user.email)
    else
      Raven.user_context(ip_address: request.ip)
    end
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
