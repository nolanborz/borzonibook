# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    session["devise.google_data"] = request.env["omniauth.auth"].except(:extra)

    # Check if user exists
    @user = User.find_by(
      provider: request.env["omniauth.auth"].provider,
      uid: request.env["omniauth.auth"].uid
    )

    if @user&.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: "Google"
      sign_in_and_redirect @user, event: :authentication
    else
      # Always redirect to invitation code form for new users
      redirect_to users_new_oauth_invitation_path
    end
  end

  def failure
    redirect_to root_path, alert: "Authentication failed, please try again."
  end
end
