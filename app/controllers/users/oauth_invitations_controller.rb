# app/controllers/users/oauth_invitations_controller.rb
class Users::OauthInvitationsController < ApplicationController
  def new
    redirect_to root_path, alert: "Please sign in with Google first." if session["devise.google_data"].blank?
  end

  def create
    oauth_data = session["devise.google_data"]

    if Rails.application.credentials.invitation_codes.include?(params[:invitation_code])
      @user = User.from_omniauth(oauth_data)
      @user.invitation_code = params[:invitation_code]

      if @user.save
        session["devise.google_data"] = nil
        sign_in_and_redirect @user, event: :authentication
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: "Google"
      else
        flash.now[:alert] = @user.errors.full_messages.join("\n")
        render :new
      end
    else
      flash.now[:alert] = "Invalid invitation code"
      render :new
    end
  end
end
