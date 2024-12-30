# app/controllers/users/oauth_invitations_controller.rb
module Users
  class OauthInvitationsController < ApplicationController
    def new
      if session["devise.google_data"].blank?
        redirect_to root_path, alert: "Please sign in with Google first."
      end
    end

    def create
      oauth_data = session["devise.google_data"]
      Rails.logger.info "Starting OAuth invitation validation"

      if params[:invitation_code] == ENV["SITE_INVITATION_CODE"]
        @user = User.from_omniauth(oauth_data)
        @user.invitation_code = params[:invitation_code]  # Set it here explicitly

        if @user.save
          Rails.logger.info "User created successfully with OAuth"
          session["devise.google_data"] = nil
          sign_in_and_redirect @user, event: :authentication
          flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: "Google"
        else
          Rails.logger.error "User save failed: #{@user.errors.full_messages}"
          flash.now[:alert] = @user.errors.full_messages.join("\n")
          render :new
        end
      else
        Rails.logger.info "Invalid invitation code provided"
        flash.now[:alert] = "Invalid invitation code"
        render :new
      end
    end
  end
end
