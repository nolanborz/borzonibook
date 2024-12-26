class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :log_sign_out_request
  before_action :debug_request

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username ])
  end
  private
  def debug_request
    Rails.logger.debug "================="
    Rails.logger.debug "Current request path: #{request.path}"
    Rails.logger.debug "Request method: #{request.method}"
    Rails.logger.debug "================="
  end
  def log_sign_out_request
    if request.path == destroy_user_session_path
      Rails.logger.debug "Sign out request received: #{request.method}"
    end
  end
end
