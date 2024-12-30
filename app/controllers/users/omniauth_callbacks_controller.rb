# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    session["devise.google_data"] = request.env["omniauth.auth"].except(:extra)

    # First, try to find an existing user
    @user = User.find_by(
      email: request.env["omniauth.auth"].info.email
    )

    if @user
      if @user.provider == "google_oauth2"
        # Existing Google OAuth user - sign them in
        sign_in_and_redirect @user, event: :authentication
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: "Google"
      else
        # User exists but didn't use Google to sign up
        flash[:alert] = "An account with this email already exists. Please sign in with your password."
        redirect_to new_user_session_path
      end
    else
      # New user - redirect to invitation code form
      redirect_to users_new_oauth_invitation_path
    end
  end

  def failure
    redirect_to root_path, alert: "Authentication failed, please try again."
  end
end
