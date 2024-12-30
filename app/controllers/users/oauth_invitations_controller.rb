# app/controllers/users/oauth_invitations_controller.rb
def new
  if session["devise.google_data"].blank?
    Rails.logger.error "OAuth data missing from session"
    redirect_to root_path, alert: "Please sign in with Google first."
  else
    Rails.logger.info "OAuth data present in session: #{session["devise.google_data"].keys}"
  end
end

def create
  oauth_data = session["devise.google_data"]
  Rails.logger.info "Creating user with OAuth data: #{oauth_data&.keys}"
  Rails.logger.info "Received invitation code: #{params[:invitation_code]}"
  Rails.logger.info "Environment invitation code: #{ENV["SITE_INVITATION_CODE"]}"

  if params[:invitation_code] == ENV["SITE_INVITATION_CODE"]
    @user = User.from_omniauth(oauth_data)
    @user.invitation_code = params[:invitation_code]

    if @user.save
      Rails.logger.info "User successfully created"
      session["devise.google_data"] = nil
      sign_in_and_redirect @user, event: :authentication
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: "Google"
    else
      Rails.logger.error "User creation failed: #{@user.errors.full_messages}"
      flash.now[:alert] = @user.errors.full_messages.join("\n")
      render :new
    end
  else
    Rails.logger.error "Invalid invitation code provided"
    flash.now[:alert] = "Invalid invitation code"
    render :new
  end
end
