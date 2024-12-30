# app/controllers/users/oauth_invitations_controller.rb
module Users
  class OauthInvitationsController < ApplicationController
    def new
      Rails.logger.tagged("OAuth Invitation - NEW") do
        if session["devise.google_data"].blank?
          Rails.logger.error "OAuth session data is missing"
          redirect_to root_path, alert: "Please sign in with Google first."
        else
          Rails.logger.info "OAuth session data found: #{session["devise.google_data"].keys}"
        end
      end
    end

    def create
      Rails.logger.tagged("OAuth Invitation - CREATE") do
        Rails.logger.info "Starting create action"
        Rails.logger.info "Format: #{request.format}"
        oauth_data = session["devise.google_data"]

        Rails.logger.info "Session data: #{oauth_data ? 'Present' : 'Missing'}"
        Rails.logger.info "Invitation code received: '#{params[:invitation_code]}'"
        Rails.logger.info "ENV code: '#{ENV["SITE_INVITATION_CODE"]}'"

        if params[:invitation_code] == ENV["SITE_INVITATION_CODE"]
          Rails.logger.info "Invitation code matches"
          @user = User.from_omniauth(oauth_data)
          @user.invitation_code = params[:invitation_code]

          if @user.save
            Rails.logger.info "User saved successfully (ID: #{@user.id})"
            session["devise.google_data"] = nil

            # Respond differently based on format
            respond_to do |format|
              format.html { sign_in_and_redirect @user, event: :authentication }
              format.turbo_stream {
                sign_in @user
                redirect_to after_sign_in_path_for(@user)
              }
            end

            flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: "Google"
          else
            Rails.logger.error "User save failed: #{@user.errors.full_messages}"
            flash.now[:alert] = @user.errors.full_messages.join("\n")
            render :new
          end
        else
          Rails.logger.error "Invitation code mismatch"
          flash.now[:alert] = "Invalid invitation code"
          render :new
        end
      end
    end
  end
end
